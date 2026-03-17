#!/usr/bin/env bash
set -euo pipefail

MINIMAL="${DOTFILES_CONTAINER_MINIMAL:-0}"

if [ "$MINIMAL" = "1" ]; then
  exit 0
fi

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
