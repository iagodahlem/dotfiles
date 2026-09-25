# Enable Powerlevel10k instant prompt. Should stay close to the top of .zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# history and the completion dump live under XDG state and cache (paths set in .zshenv), and zsh does not create the directories
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
# some /etc/zshrc files (macOS) assign HISTFILE before this file runs, so set it again
HISTFILE="$XDG_STATE_HOME/zsh/history"

# zsh configuration (ZSH and ZSH_CUSTOM come from .zshenv)
# Powerlevel10k is sourced further down, from wherever find_zsh_addon (.bootstrap) finds it, so oh-my-zsh loads no theme
ZSH_THEME=""

# scripts/install-shell.sh updates oh-my-zsh each time it runs, so oh-my-zsh must not update itself too
zstyle ':omz:update' mode disabled

plugins=(
  docker
  docker-compose
  git
  gitfast
  npm
  tmux
  z
  web-search
)

# overlays are loaded from .bootstrap

# oh-my-zsh
source $ZSH/oh-my-zsh.sh

# bootstrap
source $DOTFILES_ZSH/.bootstrap

# Powerlevel10k and zsh-autosuggestions come from the package manager where the OS has them, from the clones in $ZSH_CUSTOM where it has not
find_zsh_addon powerlevel10k && source "$REPLY"
find_zsh_addon zsh-autosuggestions && source "$REPLY"

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# To customize prompt, run `p10k configure` or edit $ZDOTDIR/.p10k.zsh.
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"

# zsh-syntax-highlighting has to be last: it wraps the widgets that everything above has bound
find_zsh_addon zsh-syntax-highlighting && source "$REPLY"
