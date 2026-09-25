#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${DOTFILES_STATE_DIR:-$HOME/.local/state/dotfiles}"
MIGRATION_MARKER="$STATE_DIR/migrated"

source "$ROOT_DIR/scripts/utils/os.sh"
OS_ID="$(os_id)"

# mise and the AI CLIs come from remote installers: a failure warns and the rest of the install carries on
run_optional() {
  "$ROOT_DIR/scripts/$1" || echo "warning: $1 failed, rerun it on its own once the cause is fixed" >&2
}

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

if [ "${DOTFILES_SKIP_MISE:-0}" != "1" ]; then
  run_optional install-mise.sh
fi

if [ "${DOTFILES_SKIP_AI_CLIS:-0}" != "1" ]; then
  run_optional install-ai-clis.sh
fi

if [ "${DOTFILES_SKIP_OS_DEFAULTS:-0}" != "1" ]; then
  case "$OS_ID" in
    macos)
      "$ROOT_DIR/os/macos.sh"
      ;;
    ubuntu|debian|raspbian)
      [ -x "$ROOT_DIR/os/ubuntu.sh" ] && "$ROOT_DIR/os/ubuntu.sh"
      ;;
    arch)
      [ -x "$ROOT_DIR/os/arch.sh" ] && "$ROOT_DIR/os/arch.sh"
      ;;
  esac
fi
