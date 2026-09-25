#!/usr/bin/env bash

# Dry-run mode, shared by the install steps and the os/ scripts: with DOTFILES_DRY_RUN=1 they print what they would do and change nothing.
# scripts/install.sh --dry-run sets it for every step.
is_dry_run() {
  [ "${DOTFILES_DRY_RUN:-0}" = "1" ]
}

# Runs a command, or in dry-run mode prints it and leaves it alone.
run() {
  if is_dry_run; then
    printf 'would run:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}
