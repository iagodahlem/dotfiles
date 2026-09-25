#!/usr/bin/env bash
# Runs the installer as a dry run in a scratch home, on the host and without Docker, and checks that every step reports and that
# nothing lands in the home. Nothing is installed, so it is safe on a machine that is already set up.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STEPS="packages dotfiles shell mise ai-clis nvim os-defaults"

fail() {
  echo "dry-run: $*" >&2
  exit 1
}

# a scratch home laid out like a machine that cloned the checkout to ~/.dotfiles
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
ln -s "$ROOT_DIR" "$scratch/.dotfiles"

# the XDG variables and DOTFILES would point the steps at the real home, so they are dropped
installer() {
  env -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u XDG_STATE_HOME -u XDG_CACHE_HOME -u DOTFILES \
    HOME="$scratch" "$ROOT_DIR/scripts/install.sh" "$@"
}

before="$(find "$scratch" -mindepth 1 | sort)"

help="$(installer --help)"
for step in $STEPS; do
  grep -q "^  $step " <<<"$help" || fail "--help does not list the $step step"
done

output="$(installer --dry-run 2>&1)" || { echo "$output"; fail "install.sh --dry-run failed"; }
echo "$output"
for step in $STEPS; do
  grep -qxF "== $step ==" <<<"$output" || fail "no '== $step ==' header in the dry run"
done

only="$(installer --only dotfiles --dry-run 2>&1)" || { echo "$only"; fail "install.sh --only dotfiles --dry-run failed"; }
if [ "$(grep -c '^== ' <<<"$only")" != 1 ] || ! grep -qxF "== dotfiles ==" <<<"$only"; then
  fail "--only dotfiles did not run just the dotfiles step"
fi

after="$(find "$scratch" -mindepth 1 | sort)"
[ "$before" = "$after" ] || fail "the dry run changed the home directory"

echo "dry-run ok"
