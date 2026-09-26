# Set PATH, MANPATH, fpath and HOMEBREW_* for the Homebrew that is installed: /opt/homebrew on macOS, Linuxbrew on Linux
for brew_exe in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -x "$brew_exe" ] || continue
  eval "$("$brew_exe" shellenv zsh)"
  # .zshenv already put the bin directory on PATH for shells that never get here, and shellenv puts it there again: keep the first of each entry
  typeset -U path
done
unset brew_exe
