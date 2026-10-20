#!/usr/bin/env bash

# A pmset action for a host overlay's install.sh (see "A machine that should never sleep" in overlays/README.md).
# Source scripts/utils/dry-run.sh first, it goes through its run(), and scripts/utils/ui.sh for report_warning.

# Keeps a machine from ever sleeping: system sleep and disk sleep off, the automatic restart after a power
# failure and wake on network access on. One sudo pmset -a call per setting, through run, so DOTFILES_DRY_RUN=1
# prints the commands and changes nothing. pmset needs sudo, like the systemsetup line in os/macos.sh; a failed
# call only warns, the same way, and does not stop the rest.
pmset_never_sleep() {
  local setting value

  for setting in sleep disksleep autorestart womp; do
    case "$setting" in
      autorestart | womp) value=1 ;;
      *) value=0 ;;
    esac
    run sudo pmset -a "$setting" "$value" || report_warning "sudo pmset -a $setting $value failed, run it by hand"
  done
}
