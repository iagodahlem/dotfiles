#!/usr/bin/env bash

# Sourced by the installer scripts and by config/zsh/.bootstrap, so the installer and the shell find the same overlay for a machine.

# Where the private overlays repo is checked out: one folder per machine, <name>/dotfiles/ being that machine's overlay.
# config/zsh/.zshenv exports the same default, so a script that has not read it still agrees with the shell.
private_dir() {
  printf '%s\n' "${DOTFILES_PRIVATE:-$HOME/.machines}"
}

# The name of this machine: DOTFILES_HOST when it is set, otherwise the short hostname in lower case.
# config/zsh/.zshenv works the same name out for the shell.
# uname -n stands in for hostname, which a minimal install does not always have (Arch ships without it).
host_id() {
  local host="${DOTFILES_HOST:-}"

  if [ -z "$host" ]; then
    host="$(uname -n)"
    host="$(printf '%s' "${host%%.*}" | tr '[:upper:]' '[:lower:]')"
  fi
  printf '%s\n' "$host"
}

# The overlay directory of this machine, or nothing when it has none. The argument is the checkout: $DOTFILES when left out.
# The first of these that exists is the whole overlay, its files are not merged with the next one's:
#   1. <private_dir>/<host_id>/dotfiles/       the private overlays repo
#   2. <checkout>/overlays/host/<host_id>/     an overlay kept in this repo
# Always succeeds, so callers test for an empty result and a set -e script survives a machine with no overlay.
host_overlay_dir() {
  local root="${1:-${DOTFILES:-$HOME/.dotfiles}}"
  local host dir

  host="$(host_id)"
  [ -n "$host" ] || return 0

  for dir in "$(private_dir)/$host/dotfiles" "$root/overlays/host/$host"; do
    if [ -d "$dir" ]; then
      printf '%s\n' "$dir"
      return 0
    fi
  done
  return 0
}
