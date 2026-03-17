#!/usr/bin/env bash
set -euo pipefail

shellcheck \
  scripts/*.sh \
  scripts/utils/*.sh \
  os/*.sh \
  containers/entrypoint.sh
