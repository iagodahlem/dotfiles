#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-dotfiles-devbox}"
DOCKERFILE="${DOCKERFILE:-containers/Dockerfile}"

docker build -f "${DOCKERFILE}" -t "${IMAGE_NAME}" .

docker run --rm "${IMAGE_NAME}" /bin/zsh -lc '\
  test -L "$HOME/.gitconfig" && \
  test -L "$HOME/.zshrc" && \
  test -L "$HOME/.tmux.conf" && \
  echo "smoke ok"'
