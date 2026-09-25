# Read by every zsh, interactive or not, so it only sets environment: no output, nothing that can fail.
# The one dotfile that stays in $HOME (scripts/install-dotfiles.sh links it): zsh reads ZDOTDIR only after /etc/zshenv, so the file that sets it cannot move.
# Plain POSIX only, because scripts/install-shell.sh sources this file from bash to resolve the same paths.

# XDG base directories, keeping any value already exported
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# zsh reads .zshrc, .p10k.zsh and the rest from here, a directory link to config/zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Ubuntu's /etc/zsh/zshrc runs compinit before ~/.zshrc does, and oh-my-zsh runs it again, so every shell built and audited the completions twice: about 11 ms of 68 in the Ubuntu image
# a parameter that file reads, not something to export; Debian and Arch run no global compinit, so it does nothing there
skip_global_compinit=1

# Homebrew on PATH for the shells that never read .zshrc: ssh runs a command (mosh-server, scp, git over ssh) in a non-interactive shell, which reads only this file
# and would find nothing brew installed. The full `brew shellenv` (MANPATH, fpath, HOMEBREW_*) stays in config/brew/.homebrew for interactive shells, which dedupes the PATH.
for brew_bin in /opt/homebrew/bin /home/linuxbrew/.linuxbrew/bin; do
  if [ -d "$brew_bin" ]; then
    case ":$PATH:" in
      *":$brew_bin:"*) ;;
      *) export PATH="$brew_bin:$PATH" ;;
    esac
  fi
done
unset brew_bin

# dotfiles
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export DOTFILES_BIN="$DOTFILES/bin"
export DOTFILES_CONFIG="$DOTFILES/config"
export DOTFILES_ZSH="$DOTFILES_CONFIG/zsh"
export DOTFILES_GIT="$DOTFILES_CONFIG/git"
export DOTFILES_OVERLAYS="$DOTFILES/overlays"

# a checkout of the private repo that holds the per-machine overlays, <name>/dotfiles/ in it being the overlay of one machine (overlays/README.md)
# scripts/install-private.sh clones it when DOTFILES_PRIVATE_REPO is set
export DOTFILES_PRIVATE="${DOTFILES_PRIVATE:-$HOME/.machines}"

# the machine this runs on, which picks its host overlay: the short hostname in lower case, unless DOTFILES_HOST is already set
# zsh has $HOST and bash $HOSTNAME, so the usual case forks nothing; uname -n covers a shell with neither (hostname is not installed everywhere)
if [ -z "${DOTFILES_HOST:-}" ]; then
  DOTFILES_HOST="${HOST:-${HOSTNAME:-$(uname -n 2>/dev/null)}}"
  DOTFILES_HOST="${DOTFILES_HOST%%.*}"
  case "$DOTFILES_HOST" in
    *[[:upper:]]*) DOTFILES_HOST="$(printf '%s' "$DOTFILES_HOST" | tr '[:upper:]' '[:lower:]')" ;;
  esac
fi
export DOTFILES_HOST

# oh-my-zsh, cloned by scripts/install-shell.sh
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export ZSH_CUSTOM="$XDG_DATA_HOME/oh-my-zsh-custom"

# tools that ignore XDG on their own
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export TMUX_PLUGIN_MANAGER_PATH="$XDG_DATA_HOME/tmux/plugins"
# the oh-my-zsh z plugin, which creates the directory (and its lock file) on first use
export ZSHZ_DATA="$XDG_DATA_HOME/z/data"

# the AI CLIs, each with a home of its own
# claude keeps settings, history and .claude.json here
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
# codex keeps config.toml, sessions and the packages of its standalone install here, and exits when the directory is missing (.zshrc creates it)
export CODEX_HOME="$XDG_DATA_HOME/codex"
# gemini creates a .gemini folder inside this one
export GEMINI_CLI_HOME="$XDG_DATA_HOME/gemini"

# macOS Terminal saves a session file per tab under ZDOTDIR, which is this checkout
export SHELL_SESSIONS_DISABLE=1

# not exported, so bash and other shells started from here keep their own history
# .zshrc creates the directories
HISTFILE="$XDG_STATE_HOME/zsh/history"
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION:-}"
