#!/usr/bin/env bash
set -euo pipefail

USER_NAME="$(cat /etc/dotfiles-user)"
if [ "$#" -gt 0 ]; then
  exec su - "${USER_NAME}" -c "$*"
else
  exec su - "${USER_NAME}" -c "/bin/zsh -l"
fi
