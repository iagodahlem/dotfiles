#!/usr/bin/env bash

os_id() {
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
