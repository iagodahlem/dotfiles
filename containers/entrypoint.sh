#!/usr/bin/env bash
set -euo pipefail

USER_NAME="$(cat /etc/dotfiles-user)"
exec su - "${USER_NAME}" -c "/bin/zsh -l"
