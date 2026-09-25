#!/usr/bin/env bash
set -euo pipefail

shellcheck \
  scripts/*.sh \
  scripts/utils/*.sh \
  ci/*.sh \
  os/*.sh \
  containers/entrypoint.sh \
  overlays/host/*/install.sh
