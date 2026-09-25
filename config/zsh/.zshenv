# Read by every zsh, interactive or not, so it only sets environment: no output, nothing that can fail.
# The one dotfile that stays in $HOME (scripts/install-dotfiles.sh links it): zsh reads ZDOTDIR only after /etc/zshenv, so the file that sets it cannot move.
# Plain POSIX assignments only, because scripts/install-shell.sh sources this file from bash to resolve the same paths.

# XDG base directories, keeping any value already exported
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# zsh reads .zshrc, .p10k.zsh and the rest from here, a directory link to config/zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# dotfiles
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export DOTFILES_BIN="$DOTFILES/bin"
export DOTFILES_CONFIG="$DOTFILES/config"
export DOTFILES_ZSH="$DOTFILES_CONFIG/zsh"
export DOTFILES_GIT="$DOTFILES_CONFIG/git"
export DOTFILES_OVERLAYS="$DOTFILES/overlays"

# oh-my-zsh, cloned by scripts/install-shell.sh
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export ZSH_CUSTOM="$XDG_DATA_HOME/oh-my-zsh-custom"

# tools that ignore XDG on their own
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export TMUX_PLUGIN_MANAGER_PATH="$XDG_DATA_HOME/tmux/plugins"

# not exported, so bash and other shells started from here keep their own history
# .zshrc creates the directories
HISTFILE="$XDG_STATE_HOME/zsh/history"
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION:-}"
