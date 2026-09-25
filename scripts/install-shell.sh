#!/usr/bin/env bash
# Clones oh-my-zsh, Powerlevel10k and the two zsh plugins, each pinned to a commit.
# Where they go comes from config/zsh/.zshenv ($ZSH and $ZSH_CUSTOM), so nothing here needs an interactive shell.
# To bump a pin: `git ls-remote <repo url> HEAD`, replace the sha below, rerun this script. An existing clone moves to the new pin.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MINIMAL="${DOTFILES_CONTAINER_MINIMAL:-0}"

if [ "$MINIMAL" = "1" ]; then
  exit 0
fi

# shellcheck source=/dev/null
source "$ROOT_DIR/config/zsh/.zshenv"

# HEAD of each repository on 2026-09-25
OMZ_REV="74965c96098134b192f00084f966b4b02438a739"
P10K_REV="d05a1b00f9a61f9578bf9dc19b8451942dde8734"
SYNTAX_HIGHLIGHTING_REV="0bfcb582e71d3abe604ce67bc0fe5a21f377507e"
AUTOSUGGESTIONS_REV="85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5"

# Puts a shallow checkout of one commit in dest. A no-op when dest is already there, so a rerun after a bump only moves what changed.
clone_pinned() {
  local url="$1"
  local rev="$2"
  local dest="$3"

  if [ -d "$dest/.git" ] && [ "$(git -C "$dest" rev-parse HEAD 2>/dev/null)" = "$rev" ]; then
    return 0
  fi

  echo "Installing ${dest#"$HOME"/} at ${rev:0:9}"
  mkdir -p "$dest"
  if [ ! -d "$dest/.git" ]; then
    git -C "$dest" init -q
    git -C "$dest" remote add origin "$url"
  fi
  git -C "$dest" fetch -q --depth 1 origin "$rev"
  git -C "$dest" checkout -q --detach FETCH_HEAD
}

clone_pinned https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_REV" "$ZSH"
clone_pinned https://github.com/romkatv/powerlevel10k.git "$P10K_REV" "$ZSH_CUSTOM/themes/powerlevel10k"
clone_pinned https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_REV" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_pinned https://github.com/zsh-users/zsh-autosuggestions.git "$AUTOSUGGESTIONS_REV" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
