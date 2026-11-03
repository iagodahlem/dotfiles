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

# The named block of `pmset -g custom` ("AC Power", "Battery Power", ...): its indented lines, up to the next
# header line (a line starting in column 1).
pmset_custom_block() {
  local header="$1"

  pmset -g custom | awk -v header="$header" '
    /^[^[:space:]]/ { in_block = (index($0, header) == 1); next }
    in_block { print }
  '
}

# The value of one key in a block pmset_custom_block printed, empty when the block has no such key.
pmset_block_value() {
  awk -v key="$1" '$1 == key { print $2; exit }' <<< "$2"
}

# Sets one key of a pmset scope ("-a" for every power source, "-c" for AC only, ...) in the named custom block,
# only when it is not already at the wanted value, through run so DOTFILES_DRY_RUN=1 prints the command and
# changes nothing; a failed call only warns, the same contract as pmset_never_sleep above.
pmset_ensure() {
  local scope="$1" block_name="$2" key="$3" want="$4" block have

  block="$(pmset_custom_block "$block_name")"
  have="$(pmset_block_value "$key" "$block")"

  if [ "$have" = "$want" ]; then
    echo "pmset $scope $key already $want"
    return 0
  fi

  echo "pmset $scope $key: ${have:-unset} -> $want"
  run sudo pmset "$scope" "$key" "$want" || report_warning "sudo pmset $scope $key $want failed, run it by hand"
}
