#!/usr/bin/env bash
# Defaults for Arch: the login shell and the docker group.
# Locale, timezone, services, the firewall and drivers are host-level settings and live in the machines repo, not here.
# Run by scripts/install.sh, or on its own. With DOTFILES_DRY_RUN=1 it prints what it would do.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/scripts/utils/dry-run.sh"
source "$ROOT_DIR/scripts/utils/linux-defaults.sh"

use_zsh_login_shell
join_docker_group
