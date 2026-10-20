#!/usr/bin/env bash
# Sourcing a script under scripts/ (to reuse its functions, say from an agent working in this repo) must never run its install
# step: every script that does work at the top level guards it behind a main, called only when the script is executed directly
# (the BASH_SOURCE/$0 guard at its end; see AGENTS.md). This sources each one with HOME pointed at an empty scratch directory
# and checks that nothing was created, removed or linked there, the way a real install step would.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "source-guard: $*" >&2
  exit 1
}

scratch=""
cleanup() {
  [ -n "$scratch" ] && rm -rf "$scratch"
  return 0
}
trap cleanup EXIT

for script in "$ROOT_DIR"/scripts/*.sh "$ROOT_DIR"/scripts/utils/*.sh; do
  name="${script#"$ROOT_DIR"/}"
  scratch="$(mktemp -d)"

  before="$(find "$scratch" -mindepth 1 | sort)"
  # the XDG variables and DOTFILES would point a script at the real home, so they are dropped, same as ci/dry-run.sh
  output="$(env -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u XDG_STATE_HOME -u XDG_CACHE_HOME -u DOTFILES -u DOTFILES_HOST -u DOTFILES_PRIVATE \
    HOME="$scratch" bash -c "source '$script'" 2>&1)" || { echo "$output"; fail "sourcing $name exited with a failure"; }
  after="$(find "$scratch" -mindepth 1 | sort)"

  if [ "$before" != "$after" ]; then
    echo "$output"
    diff <(echo "$before") <(echo "$after") || true
    fail "sourcing $name created, removed or linked something under \$HOME"
  fi

  rm -rf "$scratch"
  scratch=""
done

echo "source-guard ok"
