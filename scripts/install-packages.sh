#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$ROOT_DIR/packages"

source "$ROOT_DIR/scripts/utils/os.sh"

is_root() {
  [ "${EUID:-$(id -u)}" -eq 0 ]
}

run_as_root() {
  if is_root; then
    "$@"
  else
    sudo "$@"
  fi
}

# Entries of a package list: blank lines and comments (whole-line or trailing) are dropped.
read_list_items() {
  local list_file="$1"
  sed -E 's/[[:space:]]*#.*$//; /^[[:space:]]*$/d' "$list_file"
}

install_apt() {
  local list_file="$PACKAGES_DIR/apt.txt"
  local packages=()
  [ -f "$list_file" ] || { echo "Missing $list_file" >&2; exit 1; }

  while IFS= read -r pkg; do
    packages+=("$pkg")
  done < <(read_list_items "$list_file")

  [ "${#packages[@]}" -gt 0 ] || return 0

  run_as_root apt-get update
  run_as_root apt-get install -y --no-install-recommends "${packages[@]}"
  run_as_root rm -rf /var/lib/apt/lists/*
}

install_pacman() {
  local list_file="$PACKAGES_DIR/pacman.txt"
  local packages=()
  [ -f "$list_file" ] || { echo "Missing $list_file" >&2; exit 1; }

  while IFS= read -r pkg; do
    packages+=("$pkg")
  done < <(read_list_items "$list_file")

  [ "${#packages[@]}" -gt 0 ] || return 0

  run_as_root pacman -Syu --needed --noconfirm "${packages[@]}"
}

install_aur() {
  local list_file="$PACKAGES_DIR/aur.txt"
  local packages=()
  [ -f "$list_file" ] || return 0
  [ -n "${AUR_USER:-}" ] || return 0

  while IFS= read -r pkg; do
    packages+=("$pkg")
  done < <(read_list_items "$list_file")

  [ "${#packages[@]}" -gt 0 ] || return 0

  if ! command -v yay >/dev/null 2>&1; then
    run_as_root pacman -S --needed --noconfirm git base-devel
    run_as_root rm -rf /tmp/yay
    run_as_root git clone https://aur.archlinux.org/yay.git /tmp/yay
    run_as_root chown -R "${AUR_USER}:${AUR_USER}" /tmp/yay
    sudo -u "${AUR_USER}" bash -lc "cd /tmp/yay && makepkg -si --noconfirm"
  fi

  sudo -u "${AUR_USER}" yay -S --needed --noconfirm "${packages[@]}"
}

install_brew() {
  local brewfile="$PACKAGES_DIR/Brewfile"
  local host="${DOTFILES_HOST:-$(hostname -s)}"
  local host_brewfile="$ROOT_DIR/overlays/host/$host/Brewfile"
  local failed=0

  [ -f "$brewfile" ] || { echo "Missing $brewfile" >&2; exit 1; }

  if ! command -v brew >/dev/null 2>&1; then
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

  brew bundle --file "$brewfile" || failed=1

  if [ ! -f "$host_brewfile" ]; then
    echo "No host Brewfile for '$host' (set DOTFILES_HOST to pick one from overlays/host/)."
  elif [ -z "$(read_list_items "$host_brewfile")" ]; then
    echo "Host Brewfile for '$host' has no entries."
  else
    brew bundle --file "$host_brewfile" || failed=1
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
  ubuntu|debian)
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
