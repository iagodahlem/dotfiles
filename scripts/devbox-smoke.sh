#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-dotfiles-devbox}"
DOCKERFILE="${DOCKERFILE:-containers/Dockerfile}"
DOCKER_BUILD_ARGS="${DOCKER_BUILD_ARGS:-}"

if [ -n "$DOCKER_BUILD_ARGS" ]; then
  # shellcheck disable=SC2086
  docker build -f "${DOCKERFILE}" -t "${IMAGE_NAME}" $DOCKER_BUILD_ARGS .
else
  docker build -f "${DOCKERFILE}" -t "${IMAGE_NAME}" .
fi

docker run --rm "${IMAGE_NAME}" /bin/zsh -lc '\
  test "$(id -u)" -ne 0 && \
  test -L "$HOME/.gitconfig" && \
  test -L "$HOME/.zshrc" && \
  test -L "$HOME/.tmux.conf" && \
  echo "smoke ok"'
