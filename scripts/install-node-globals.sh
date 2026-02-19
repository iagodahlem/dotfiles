#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST_FILE="$ROOT_DIR/config/npm/globals"

if [ ! -f "$LIST_FILE" ]; then
  exit 0
fi

if ! command -v pnpm >/dev/null 2>&1; then
  if command -v corepack >/dev/null 2>&1; then
    corepack enable
    corepack prepare pnpm@latest --activate
  else
    echo "pnpm not found and corepack is unavailable." >&2
    exit 1
  fi
fi

pnpm add -g $(grep -v '^#' "$LIST_FILE" | xargs)
