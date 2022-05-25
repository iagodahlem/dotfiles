# path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# zsh configuration
ZSH_THEME="dracula"
ZSH_CUSTOM="$HOME/.custom"

plugins=(
  asdf                      # asdf autocompletion
  docker                    # docker autocompletion
  git                       # git aliases
  gitfast                   # git faster autocompletion
  npm                       # npm autocompletion
  tmux                      # tmux behavior and aliases
  yarn                      # yarn autocompletion
  z                         # `z` navigator
  zsh-syntax-highlighting   # syntax highlighting for zsh
)

# config
export DOTFILES="$HOME/.dotfiles"
export DOTFILES_BIN="$DOTFILES/bin"
export DOTFILES_ZSH="$DOTFILES/zsh"
export DOTFILES_GIT="$DOTFILES/git"

# bootstrap
source $DOTFILES_ZSH/.bootstrap

# extensions
for EXTENSION in "$DOTFILES"/extensions/*/zsh/.zshrc; do
  [ -r $EXTENSION ] && source $EXTENSION
done
unset EXTENSION

source $ZSH/oh-my-zsh.sh
