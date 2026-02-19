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

install_apt() {
  local list_file="$PACKAGES_DIR/apt.txt"
  [ -f "$list_file" ] || { echo "Missing $list_file" >&2; exit 1; }

  run_as_root apt-get update
  run_as_root apt-get install -y --no-install-recommends $(grep -v '^#' "$list_file" | xargs)
  run_as_root rm -rf /var/lib/apt/lists/*
}

install_pacman() {
  local list_file="$PACKAGES_DIR/pacman.txt"
  [ -f "$list_file" ] || { echo "Missing $list_file" >&2; exit 1; }

  run_as_root pacman -Syy --noconfirm
  run_as_root pacman -S --needed --noconfirm $(grep -v '^#' "$list_file" | xargs)
}

install_aur() {
  local list_file="$PACKAGES_DIR/aur.txt"
  [ -f "$list_file" ] || return 0
  [ -n "${AUR_USER:-}" ] || return 0

  if ! command -v yay >/dev/null 2>&1; then
    run_as_root pacman -S --needed --noconfirm git base-devel
    run_as_root rm -rf /tmp/yay
    run_as_root git clone https://aur.archlinux.org/yay.git /tmp/yay
    run_as_root chown -R "${AUR_USER}:${AUR_USER}" /tmp/yay
    sudo -u "${AUR_USER}" bash -lc "cd /tmp/yay && makepkg -si --noconfirm"
  fi

  sudo -u "${AUR_USER}" yay -S --needed --noconfirm $(grep -v '^#' "$list_file" | xargs)
}

install_brew() {
  local brewfile="$PACKAGES_DIR/Brewfile"
  local caskfile="$PACKAGES_DIR/Caskfile"
  local fontfile="$PACKAGES_DIR/Fontfile"

  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  if [ -f "$brewfile" ]; then
    brew install $(grep -v '^#' "$brewfile" | xargs)
  fi

  brew tap homebrew/cask || true
  brew tap homebrew/cask-versions || true
  brew tap homebrew/cask-fonts || true

  if [ -f "$caskfile" ]; then
    brew install --cask $(grep -v '^#' "$caskfile" | xargs)
  fi

  if [ -f "$fontfile" ]; then
    brew install --cask $(grep -v '^#' "$fontfile" | xargs)
  fi
}

OS_ID="$(os_id)"

case "$OS_ID" in
  darwin)
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
