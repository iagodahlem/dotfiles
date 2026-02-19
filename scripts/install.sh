#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATION_MARKER="$ROOT_DIR/.migrated"

os_id() {
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "macos"
    return
  fi
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "${ID:-unknown}"
    return
  fi
  echo "unknown"
}

OS_ID="$(os_id)"

if [ ! -f "$MIGRATION_MARKER" ]; then
  if [ -d "$ROOT_DIR/zsh" ] || [ -d "$ROOT_DIR/git" ] || [ -d "$ROOT_DIR/tmux" ]; then
    echo "Detected legacy layout (e.g. zsh/, git/, tmux/)."
    echo "Re-running install will update symlinks to config/."
  fi
  touch "$MIGRATION_MARKER"
fi

if [ "${DOTFILES_SKIP_PACKAGES:-0}" != "1" ]; then
  if [ "$OS_ID" = "macos" ]; then
    if command -v brew >/dev/null 2>&1; then
      brew install $(cat "$ROOT_DIR/packages/Brewfile" | grep -v "#")
    else
      echo "Homebrew not found. Install it first." >&2
      exit 1
    fi
  else
    "$ROOT_DIR/scripts/install-packages.sh"
  fi
fi

if [ "${DOTFILES_SKIP_DOTFILES:-0}" != "1" ]; then
  "$ROOT_DIR/scripts/install-dotfiles.sh"
fi

if [ "${DOTFILES_SKIP_SHELL:-0}" != "1" ]; then
  "$ROOT_DIR/scripts/install-shell.sh"
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
