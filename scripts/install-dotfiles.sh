#!/usr/bin/env bash
set -euo pipefail

DOTS="${DOTS:-$HOME/.dotfiles}"
CONFIG_DIR="${DOTFILES_CONFIG_DIR:-$DOTS/config}"
VSCODE_CONFIG="${VSCODE_CONFIG:-$HOME/Library/Application Support/Code/User}"

safe_link() {
  local src="$1"
  local dst="$2"
  local ts

  if [ ! -e "$src" ]; then
    return 0
  fi

  if [ -L "$dst" ]; then
    rm -f "$dst"
  elif [ -e "$dst" ]; then
    ts="$(date +%Y%m%d%H%M%S)"
    mv "$dst" "${dst}.bak.${ts}"
  fi

  ln -s "$src" "$dst"
}

# git
safe_link "$CONFIG_DIR/git/.gitconfig" "$HOME/.gitconfig"
safe_link "$CONFIG_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
safe_link "$CONFIG_DIR/git/.gitmessage" "$HOME/.gitmessage"

# zsh
safe_link "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
safe_link "$CONFIG_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# tmux
safe_link "$CONFIG_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# vim
safe_link "$CONFIG_DIR/vim/.vimrc" "$HOME/.vimrc"

# vscode
if [ -d "$VSCODE_CONFIG" ]; then
  safe_link "$CONFIG_DIR/vscode/snippets" "$VSCODE_CONFIG/snippets"
  safe_link "$CONFIG_DIR/vscode/keybindings.json" "$VSCODE_CONFIG/keybindings.json"
  safe_link "$CONFIG_DIR/vscode/settings.json" "$VSCODE_CONFIG/settings.json"
fi

# asdf, nvm, atuin
safe_link "$CONFIG_DIR/asdf/.tool-versions" "$HOME/.tool-versions"
safe_link "$CONFIG_DIR/asdf/.asdfrc" "$HOME/.asdfrc"
