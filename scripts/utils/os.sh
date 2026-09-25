#!/usr/bin/env bash

os_id() {
  # DOTFILES_OS_ID stands in for the detected OS, so a test can exercise the macos entries of config/links on a Linux host.
  if [ -n "${DOTFILES_OS_ID:-}" ]; then
    echo "$DOTFILES_OS_ID"
    return
  fi
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "macos"
    return
  fi
  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "${ID:-unknown}"
    return
  fi
  echo "unknown"
}
