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
  test -L "$HOME/.zshenv" && \
  test -L "$HOME/.config/zsh" && \
  test -L "$HOME/.config/tmux" && \
  test -L "$HOME/.config/nvim" && \
  test -L "$HOME/.config/git" && \
  test "$(readlink "$HOME/.config/git")" = "$HOME/.dotfiles/config/git" && \
  test -f "$HOME/.config/git/config" && \
  test "$ZDOTDIR" = "$HOME/.config/zsh" && \
  { [ ! -d "$ZSH" ] || test -z "$(/bin/zsh -ic true 2>&1)"; } && \
  "$HOME/.dotfiles/scripts/install.sh" --dry-run --yes | grep "^==> summary" >/dev/null && \
  echo "smoke ok"'
