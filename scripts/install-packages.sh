#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$ROOT_DIR/packages"

source "$ROOT_DIR/scripts/utils/os.sh"
source "$ROOT_DIR/scripts/utils/lists.sh"
source "$ROOT_DIR/scripts/utils/dry-run.sh"

is_root() {
  [ "${EUID:-$(id -u)}" -eq 0 ]
}

run_as_root() {
  if is_root; then
    run "$@"
  else
    run sudo "$@"
  fi
}

install_apt() {
  local list_file="$PACKAGES_DIR/apt.txt"
  local packages=()
  local available=()
  local pkg candidate
  [ -f "$list_file" ] || { echo "Missing $list_file" >&2; exit 1; }

  while IFS= read -r pkg; do
    packages+=("$pkg")
  done < <(read_list_items "$list_file")

  [ "${#packages[@]}" -gt 0 ] || return 0

  if is_dry_run; then
    describe_list "$list_file"
  fi

  run "$ROOT_DIR/scripts/install-apt-repos.sh"
  run_as_root apt-get update

  if is_dry_run; then
    # the third-party sources are not added in a dry run, so apt cannot say which packages have a candidate
    available=("${packages[@]}")
  else
    # one missing package would fail the whole apt-get install, and releases differ (fastfetch is Debian 13 and newer)
    for pkg in "${packages[@]}"; do
      candidate="$(apt-cache policy "$pkg" 2>/dev/null | awk '/Candidate:/ { c = $2 } END { print c }' || true)"
      if [ -n "$candidate" ] && [ "$candidate" != "(none)" ]; then
        available+=("$pkg")
      else
        echo "warning: no apt candidate for $pkg on this release, skipping it" >&2
      fi
    done
  fi

  if [ "${#available[@]}" -gt 0 ]; then
    run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${available[@]}"
  fi
  run_as_root sh -c 'rm -rf /var/lib/apt/lists/*'
}

install_pacman() {
  local list_file="$PACKAGES_DIR/pacman.txt"
  local packages=()
  [ -f "$list_file" ] || { echo "Missing $list_file" >&2; exit 1; }

  while IFS= read -r pkg; do
    packages+=("$pkg")
  done < <(read_list_items "$list_file")

  [ "${#packages[@]}" -gt 0 ] || return 0

  if is_dry_run; then
    describe_list "$list_file"
  fi

  run_as_root pacman -Syu --needed --noconfirm "${packages[@]}"
}

install_aur() {
  local list_file="$PACKAGES_DIR/aur.txt"
  local packages=()
  [ -f "$list_file" ] || return 0

  if [ -z "${AUR_USER:-}" ]; then
    if is_dry_run; then
      echo "AUR_USER is not set, so $(display_path "$list_file") would be skipped"
    fi
    return 0
  fi

  while IFS= read -r pkg; do
    packages+=("$pkg")
  done < <(read_list_items "$list_file")

  [ "${#packages[@]}" -gt 0 ] || return 0

  if is_dry_run; then
    describe_list "$list_file"
  fi

  if ! command -v yay >/dev/null 2>&1; then
    run_as_root pacman -S --needed --noconfirm git base-devel
    run_as_root rm -rf /tmp/yay
    run_as_root git clone https://aur.archlinux.org/yay.git /tmp/yay
    run_as_root chown -R "${AUR_USER}:${AUR_USER}" /tmp/yay
    run sudo -u "${AUR_USER}" bash -lc "cd /tmp/yay && makepkg -si --noconfirm"
  fi

  run sudo -u "${AUR_USER}" yay -S --needed --noconfirm "${packages[@]}"
}

install_brew() {
  local brewfile="$PACKAGES_DIR/Brewfile"
  local host="${DOTFILES_HOST:-$(hostname -s)}"
  local host_brewfile="$ROOT_DIR/overlays/host/$host/Brewfile"
  local failed=0

  [ -f "$brewfile" ] || { echo "Missing $brewfile" >&2; exit 1; }

  if is_dry_run; then
    describe_list "$brewfile"
  fi

  if command -v brew >/dev/null 2>&1; then
    if is_dry_run; then
      echo "Homebrew: already installed"
    fi
  elif is_dry_run; then
    echo "Homebrew: not installed, would run its installer with NONINTERACTIVE=1 (https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew not found. Installing..."
    # the non-interactive installer only checks for cached sudo credentials, it never asks for a password
    is_root || sudo -v
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  run brew bundle --file "$brewfile" || failed=1

  if [ ! -f "$host_brewfile" ]; then
    echo "No host Brewfile for '$host' (set DOTFILES_HOST to pick one from overlays/host/)."
  elif [ -z "$(read_list_items "$host_brewfile")" ]; then
    echo "Host Brewfile for '$host' has no entries."
  else
    if is_dry_run; then
      describe_list "$host_brewfile"
    fi
    run brew bundle --file "$host_brewfile" || failed=1
  fi

  if [ "$failed" -ne 0 ]; then
    echo "Some Brewfile entries failed to install (an app that already exists outside Homebrew is one common cause). Fix them and rerun brew bundle --file on the Brewfile." >&2
  fi
}

OS_ID="$(os_id)"

case "$OS_ID" in
  macos)
    install_brew
    ;;
  ubuntu|debian|raspbian)
    install_apt
    ;;
  arch)
    install_pacman
    install_aur
    ;;
  *)
    if [ "$(uname -s)" = "Darwin" ]; then
      install_brew
    else
      echo "Unsupported OS for package install. Set up manually." >&2
      exit 1
    fi
    ;;
esac
