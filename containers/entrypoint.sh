#!/usr/bin/env bash
set -euo pipefail

USER_NAME="$(cat /etc/dotfiles-user)"
if [ "$#" -gt 0 ]; then
  USER_CMD="$(printf '%q ' "$@")"
  exec su - "${USER_NAME}" -c "${USER_CMD% }"
else
  exec su - "${USER_NAME}" -c "/bin/zsh -l"
fi
