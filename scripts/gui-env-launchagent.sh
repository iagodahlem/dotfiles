#!/usr/bin/env bash
# Run by the local.dotfiles.gui-env LaunchAgent (installed by scripts/install-dotfiles.sh) at every login.
# launchd never runs a login shell, so a GUI app it spawns, the Codex and Claude Code desktop apps among them, does
# not see the redirects config/zsh/.zshenv exports for the shell. launchctl setenv puts a variable in every GUI
# app's environment instead, but only until the next reboot, so this has to run again at each login rather than
# once at install time.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/utils/zshenv.sh"

# Sets or clears every var name passed in launchd's environment, resolved via resolve_zshenv_vars so a machine's
# local.zshenv is honoured (sourcing $HOME/.zshenv straight from this script's own bash, the one copy of either
# value it used to keep, never reaches it, the same reason resolve_zshenv_vars exists). A var that resolves unset
# there is cleared with unsetenv, rather than pinned to whatever the plain bash source below would have computed.
# Falls back to that plain bash source, with a warning, only when zsh itself is missing.
apply_gui_env() {
  local line var value

  if command -v zsh >/dev/null 2>&1; then
    while IFS= read -r line; do
      var="${line%%=*}"
      value="${line#*=}"
      if [ "$value" = "$ZSHENV_UNSET_MARK" ]; then
        launchctl unsetenv "$var"
      else
        launchctl setenv "$var" "$value"
      fi
    done < <(resolve_zshenv_vars "$@")
    return 0
  fi

  echo "warning: zsh not found, falling back to sourcing \$HOME/.zshenv from bash (a machine's local.zshenv overrides are zsh-only and will not apply)" >&2
  # shellcheck source=/dev/null
  source "$HOME/.zshenv"
  for var in "$@"; do
    launchctl setenv "$var" "${!var}"
  done
}

main() {
  # the two vars above with a macOS desktop app of their own, not just a CLI; see "The home directory after an
  # install" in README.md for the rest of the XDG redirects, which stay shell-only on purpose
  apply_gui_env CLAUDE_CONFIG_DIR CODEX_HOME
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
