#!/usr/bin/env bash
set -euo pipefail

os_id() {
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "macos"
    return
  fi
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "${ID:-unknown}"
    return
  fi
  echo "unknown"
}
