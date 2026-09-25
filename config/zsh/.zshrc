# Enable Powerlevel10k instant prompt. Should stay close to the top of .zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# history and the completion dump live under XDG state and cache (paths set in .zshenv), and zsh does not create the directories
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
# codex refuses to start when CODEX_HOME does not exist
[[ -d "$CODEX_HOME" ]] || mkdir -p "$CODEX_HOME"
# some /etc/zshrc files (macOS) assign HISTFILE before this file runs, so set it again
HISTFILE="$XDG_STATE_HOME/zsh/history"

# zsh configuration (ZSH and ZSH_CUSTOM come from .zshenv)
ZSH_THEME="powerlevel10k/powerlevel10k"

# scripts/install-shell.sh updates oh-my-zsh and its plugins each time it runs, so oh-my-zsh must not update itself too
zstyle ':omz:update' mode disabled

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
)

# overlays are loaded from .bootstrap

# oh-my-zsh
source $ZSH/oh-my-zsh.sh

# bootstrap
source $DOTFILES_ZSH/.bootstrap

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# To customize prompt, run `p10k configure` or edit $ZDOTDIR/.p10k.zsh.
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"
