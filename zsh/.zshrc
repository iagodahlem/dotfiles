# path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# zsh configuration
ZSH_THEME="dracula-pro"
ZSH_CUSTOM="$HOME/.custom"

plugins=(
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
