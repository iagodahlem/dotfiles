#!/usr/bin/env bash
# Checks out the private overlays repo at $DOTFILES_PRIVATE (~/.machines by default), or fast-forwards it when it is already there.
# The repo holds one folder per machine, <name>/dotfiles/ being that machine's overlay (see overlays/README.md). Its address is never in this
# repo: set DOTFILES_PRIVATE_REPO to it, in the ssh form, and make sure the key of this machine can reach it. Without one, nothing is cloned.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/scripts/utils/dry-run.sh"
source "$ROOT_DIR/scripts/utils/host.sh"
source "$ROOT_DIR/scripts/utils/ui.sh"

REPO="${DOTFILES_PRIVATE_REPO:-}"
DEST="$(private_dir)"

# a checkout has .git, a directory or, for a worktree, a file
if [ -e "$DEST/.git" ]; then
  if is_dry_run; then
    echo "$(display_path "$DEST"): already cloned, would run git pull --ff-only"
    exit 0
  fi
  # an existing checkout still works when it cannot be updated (offline, a diverged branch), so it stays as it is
  git -C "$DEST" pull -q --ff-only || report_warning "could not update $(display_path "$DEST"), leaving it as it is"
  exit 0
fi

# a directory somebody filled by hand is used as it is, and git would refuse to clone into it
if [ -d "$DEST" ] && [ -n "$(ls -A "$DEST")" ]; then
  echo "$(display_path "$DEST"): not a git checkout, using it as it is"
  exit 0
fi

if [ -z "$REPO" ]; then
  echo "private overlays are off: set DOTFILES_PRIVATE_REPO to the repo of your overlays, ssh form, to clone it to $(display_path "$DEST")"
  exit 0
fi

if ! is_dry_run; then
  echo "cloning $REPO into $(display_path "$DEST")"
fi
run git clone --depth 1 "$REPO" "$DEST"
