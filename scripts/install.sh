#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${DOTFILES_STATE_DIR:-$HOME/.local/state/dotfiles}"
MIGRATION_MARKER="$STATE_DIR/migrated"

source "$ROOT_DIR/scripts/utils/os.sh"
OS_ID="$(os_id)"

if [ ! -f "$MIGRATION_MARKER" ]; then
  mkdir -p "$STATE_DIR"
  if [ -d "$ROOT_DIR/zsh" ] || [ -d "$ROOT_DIR/git" ] || [ -d "$ROOT_DIR/tmux" ]; then
    echo "Detected legacy layout (e.g. zsh/, git/, tmux/)."
    echo "Re-running install will update symlinks to config/."
  fi
  touch "$MIGRATION_MARKER"
fi

if [ "${DOTFILES_SKIP_PACKAGES:-0}" != "1" ]; then
  "$ROOT_DIR/scripts/install-packages.sh"
fi

if [ "${DOTFILES_SKIP_DOTFILES:-0}" != "1" ]; then
  "$ROOT_DIR/scripts/install-dotfiles.sh"
fi

if [ "${DOTFILES_SKIP_SHELL:-0}" != "1" ]; then
  "$ROOT_DIR/scripts/install-shell.sh"
fi

if [ "${DOTFILES_SKIP_NODE_GLOBALS:-0}" != "1" ]; then
  "$ROOT_DIR/scripts/install-node-globals.sh"
fi

if [ "${DOTFILES_SKIP_OS_DEFAULTS:-0}" != "1" ]; then
  case "$OS_ID" in
    macos)
      "$ROOT_DIR/os/macos.sh"
      ;;
    ubuntu|debian)
      [ -x "$ROOT_DIR/os/ubuntu.sh" ] && "$ROOT_DIR/os/ubuntu.sh"
      ;;
    arch)
      [ -x "$ROOT_DIR/os/arch.sh" ] && "$ROOT_DIR/os/arch.sh"
      ;;
  esac
fi
