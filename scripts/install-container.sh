#!/usr/bin/env bash
set -euo pipefail

DOTS="${DOTS:-$HOME/.dotfiles}"
export DOTFILES_INSTALL_MODE="${DOTFILES_INSTALL_MODE:-container}"
export DOTFILES_CONTAINER_MINIMAL="${DOTFILES_CONTAINER_MINIMAL:-0}"

if [ "$DOTFILES_INSTALL_MODE" != "container" ]; then
  echo "This installer is intended for container use only. Set DOTFILES_INSTALL_MODE=container." >&2
  exit 1
fi

"$DOTS/scripts/install-dotfiles.sh"
"$DOTS/scripts/install-shell.sh"

echo "Container dotfiles install complete."
