#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$ROOT_DIR/packages"

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

if [ -f /etc/os-release ]; then
  . /etc/os-release
fi

case "${ID:-}" in
  ubuntu|debian)
    install_apt
    ;;
  arch)
    install_pacman
    install_aur
    ;;
  *)
    echo "Unsupported OS for package install. Set up manually." >&2
    exit 1
    ;;
esac
