# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# zsh configuration
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_CUSTOM="$HOME/.custom"

plugins=(
  docker
  docker-compose
  git
  gitfast
  npm
  tmux
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
  web-search
)

# config
export DOTFILES="$HOME/.dotfiles"
export DOTFILES_BIN="$DOTFILES/bin"
export DOTFILES_CONFIG="$DOTFILES/config"
export DOTFILES_ZSH="$DOTFILES_CONFIG/zsh"
export DOTFILES_GIT="$DOTFILES_CONFIG/git"
export DOTFILES_OVERLAYS="$DOTFILES/overlays"

# overlays are loaded from .bootstrap

# oh-my-zsh
source $ZSH/oh-my-zsh.sh

# bootstrap
source $DOTFILES_ZSH/.bootstrap

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# pnpm
export PNPM_HOME="/home/iagodahlem/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
