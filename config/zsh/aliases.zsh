# dotfiles
alias dots="cd $DOTFILES"

# disk, processes, containers
if command -v duf >/dev/null 2>&1; then
  alias df="duf"
else
  alias df="df -h"
fi
if command -v ncdu >/dev/null 2>&1; then
  alias du="ncdu"
else
  alias du="du -h -d 2"
fi
# plain non-interactive form; `command` keeps it off the du alias above
alias dus="command du -h -d 2"
if command -v procs >/dev/null 2>&1; then
  alias ps="procs"
fi

# override rm -i alias which makes rm prompt for every action
alias rm='nocorrect rm'

# general commands
alias top="btop"

# bat is installed as batcat on Debian
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
elif command -v batcat >/dev/null 2>&1; then
  alias cat="batcat"
fi

# fd is installed as fdfind on Debian
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd="fdfind"
fi

# ls and lt through eza (exa on older Debian), falling back to plain ls
# oh-my-zsh's ll, la and l are aliases of ls, so they resolve to eza through the ls alias
if command -v eza >/dev/null 2>&1; then
  _ls_bin="eza"
elif command -v exa >/dev/null 2>&1; then
  _ls_bin="exa"
fi
if [ -n "${_ls_bin:-}" ]; then
  alias ls="$_ls_bin --group-directories-first"
  alias lt="$_ls_bin --tree --level=2 --group-directories-first"
fi
unset _ls_bin

# zsh & oh-my-zsh
alias reload=". $ZDOTDIR/.zshrc"
alias r="reload"

# docker
alias dc="docker"
alias dcc="docker compose"
