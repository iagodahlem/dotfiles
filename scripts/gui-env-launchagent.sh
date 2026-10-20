#!/usr/bin/env bash
# Run by the local.dotfiles.gui-env LaunchAgent (installed by scripts/install-dotfiles.sh) at every login.
# launchd never runs a login shell, so a GUI app it spawns, the Codex and Claude Code desktop apps among them, does
# not see the redirects config/zsh/.zshenv exports for the shell. launchctl setenv puts a variable in every GUI
# app's environment instead, but only until the next reboot, so this has to run again at each login rather than
# once at install time.
set -euo pipefail

# the one dotfile install-dotfiles.sh always leaves at a fixed path in $HOME: read it instead of keeping a second
# copy of CODEX_HOME and CLAUDE_CONFIG_DIR here, so this follows wherever they actually point on this machine
# shellcheck source=/dev/null
source "$HOME/.zshenv"

# the two vars above with a macOS desktop app of their own, not just a CLI; see "The home directory after an
# install" in README.md for the rest of the XDG redirects, which stay shell-only on purpose
for var in CLAUDE_CONFIG_DIR CODEX_HOME; do
  launchctl setenv "$var" "${!var}"
done
