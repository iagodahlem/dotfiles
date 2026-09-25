#!/usr/bin/env bash

# Puts tools installed earlier in the same run on PATH (Homebrew, ~/.local/bin),
# since the shell rc files that normally do it have not run in an installer.
setup_tool_path() {
  local brew_bin
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew_bin" ]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done

  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
}
