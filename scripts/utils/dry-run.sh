#!/usr/bin/env bash

# Dry-run mode, shared by the install steps and the os/ scripts: with DOTFILES_DRY_RUN=1 they print what they would do and change nothing.
# scripts/install.sh --dry-run sets it for every step.
is_dry_run() {
  [ "${DOTFILES_DRY_RUN:-0}" = "1" ]
}

# An argument as it would be typed at a prompt: bare when it is plain, in single quotes when it is not.
quote_arg() {
  case "$1" in
    "" | *[!A-Za-z0-9_@%+=:,./~-]*)
      printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
      ;;
    *)
      printf '%s' "$1"
      ;;
  esac
}

# Runs a command, or in dry-run mode prints it and leaves it alone.
run() {
  local arg line="would run:"

  if is_dry_run; then
    for arg in "$@"; do
      line="$line $(quote_arg "$arg")"
    done
    echo "$line"
  else
    "$@"
  fi
}

# A path as it reads best in the output: relative to the checkout ($ROOT_DIR must be set), or with ~ for the home directory.
display_path() {
  case "$1" in
    "$ROOT_DIR"/*) echo "${1#"$ROOT_DIR"/}" ;;
    "$HOME"/*) echo "${1/#"$HOME"/\~}" ;;
    *) echo "$1" ;;
  esac
}

# "<path>: N entries" for a list file, as read_list_items counts them (source scripts/utils/lists.sh too).
describe_list() {
  local count
  count="$(count_list_items "$1")"

  if [ "$count" = "1" ]; then
    echo "$(display_path "$1"): 1 entry"
  else
    echo "$(display_path "$1"): $count entries"
  fi
}
