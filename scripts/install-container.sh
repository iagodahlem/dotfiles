#!/usr/bin/env bash
set -euo pipefail

DOTS="${DOTS:-$HOME/.dotfiles}"
INSTALL_MODE="${DOTFILES_INSTALL_MODE:-container}"
MINIMAL="${DOTFILES_CONTAINER_MINIMAL:-0}"

safe_link() {
  local src="$1"
  local dst="$2"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    rm -rf "$dst"
  fi
  ln -s "$src" "$dst"
}

if [ "$INSTALL_MODE" != "container" ]; then
  echo "This installer is intended for container use only. Set DOTFILES_INSTALL_MODE=container." >&2
  exit 1
fi

# Core symlinks
safe_link "$DOTS/git/.gitconfig" "$HOME/.gitconfig"
safe_link "$DOTS/git/.gitignore_global" "$HOME/.gitignore_global"
safe_link "$DOTS/git/.gitmessage" "$HOME/.gitmessage"
safe_link "$DOTS/zsh/.zshrc" "$HOME/.zshrc"
safe_link "$DOTS/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
safe_link "$DOTS/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Optional: oh-my-zsh + plugins
if [ "$MINIMAL" = "0" ]; then
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  mkdir -p "$HOME/.custom/plugins" "$HOME/.custom/themes"

  if [ ! -d "$HOME/.custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.custom/themes/powerlevel10k"
  fi

  if [ ! -d "$HOME/.custom/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.custom/plugins/zsh-syntax-highlighting"
  fi

  if [ ! -d "$HOME/.custom/plugins/zsh-autosuggestions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.custom/plugins/zsh-autosuggestions"
  fi
fi

# Extensions (if present in the repo)
if [ -d "$DOTS/extensions" ]; then
  mkdir -p "$DOTS/extensions"
fi

echo "Container dotfiles install complete."
