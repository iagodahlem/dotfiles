#!/usr/bin/env bash
# Syncs the LazyVim plugins headless, from the config that install-dotfiles.sh links at ~/.config/nvim.
# Needs neovim 0.9 or newer: an older one (Debian 12 ships 0.7) gets a warning and is skipped.
# The sync writes lazy-lock.json next to init.lua, so commit it to pin the plugin versions.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIN_MINOR=9

source "$ROOT_DIR/scripts/utils/paths.sh"
# shellcheck source=/dev/null
source "$ROOT_DIR/config/zsh/.zshenv"

setup_tool_path

if ! command -v nvim >/dev/null 2>&1; then
  echo "warning: nvim is not installed, skipping the plugin sync" >&2
  exit 0
fi

version="$(nvim --version | sed -n '1s/^NVIM v\([0-9]*\)\.\([0-9]*\).*/\1.\2/p')"
major="${version%%.*}"
minor="${version#*.}"
if [ -z "$version" ]; then
  echo "warning: could not read the nvim version, skipping the plugin sync" >&2
  exit 0
fi
if [ "$major" -eq 0 ] && [ "$minor" -lt "$MIN_MINOR" ]; then
  echo "warning: nvim $version is older than 0.$MIN_MINOR, skipping the plugin sync (LazyVim needs a newer neovim)" >&2
  exit 0
fi

if [ ! -f "$XDG_CONFIG_HOME/nvim/init.lua" ]; then
  echo "warning: $XDG_CONFIG_HOME/nvim/init.lua not found, run scripts/install-dotfiles.sh first" >&2
  exit 0
fi

nvim --headless "+Lazy! sync" +qa
