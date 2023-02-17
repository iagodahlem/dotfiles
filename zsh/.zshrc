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
  yarn
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
  web-search
)

# config
export DOTFILES="$HOME/.dotfiles"
export DOTFILES_BIN="$DOTFILES/bin"
export DOTFILES_ZSH="$DOTFILES/zsh"
export DOTFILES_GIT="$DOTFILES/git"
export DOTFILES_EXTENSIONS="$DOTFILES/extensions"

# extensions
[ -d "$DOTFILES_EXTENSIONS" ] && for EXTENSION_ZSH in "$DOTFILES_EXTENSIONS"/*/zsh/.zshrc; do
  [ -r $EXTENSION_ZSH ] && source $EXTENSION_ZSH
done
unset EXTENSION_ZSH

# oh-my-zsh
source $ZSH/oh-my-zsh.sh

# bootstrap
source $DOTFILES_ZSH/.bootstrap

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
