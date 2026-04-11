#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST_FILE="$ROOT_DIR/config/npm/globals"

if [ ! -f "$LIST_FILE" ]; then
  exit 0
fi

PACKAGES="$(grep -Ev '^[[:space:]]*($|#)' "$LIST_FILE" | xargs || true)"
if [ -z "$PACKAGES" ]; then
  exit 0
fi

if ! command -v pnpm >/dev/null 2>&1; then
  if command -v corepack >/dev/null 2>&1; then
    if ! corepack enable || ! corepack prepare pnpm@latest --activate; then
      echo "Skipping npm globals: unable to bootstrap pnpm via corepack." >&2
      exit 0
    fi
  else
    echo "Skipping npm globals: pnpm/corepack not available." >&2
    exit 0
  fi
fi

pnpm add -g $PACKAGES
