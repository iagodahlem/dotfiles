#!/usr/bin/env bash

# What scripts/install.sh prints around the steps: a banner, one header per step, a status line that closes it, and a summary at the end.
# A step's own output stays as it is. Colour and bold only when stdout is a terminal and NO_COLOR is not set, so CI logs and pipes get plain text.
# Kept to what bash 3.2, the one macOS ships, has: no associative arrays and no ${var,,}.
#
# The lines share a prefix, so a log scans: "==>" opens a step, and "ok", "skip", "warn" and "fail" close it, "note" adds a remark.
# A step can raise warnings of its own through report_warning at the bottom; the summary lists them with the ones install.sh raises.

_UI_READY=""
_UI_BOLD=""
_UI_DIM=""
_UI_RED=""
_UI_GREEN=""
_UI_YELLOW=""
_UI_CYAN=""
_UI_RESET=""
_UI_DIR=""
_UI_WARNINGS=""
_UI_RESULTS=""
_UI_STEP=""
_UI_STEP_START=0
_UI_STEP_WARNINGS=0
_UI_RUN_START=""

# Picks the palette on first use: all empty, so every line below prints plain, unless stdout is a terminal that has colours and NO_COLOR is unset.
_ui_init() {
  local colors

  if [ -n "$_UI_READY" ]; then
    return 0
  fi
  _UI_READY=1

  if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && command -v tput >/dev/null 2>&1; then
    colors="$(tput colors 2>/dev/null || true)"
    case "$colors" in
      "" | *[!0-9]*) colors=0 ;;
    esac
    if [ "$colors" -ge 8 ]; then
      _UI_BOLD="$(tput bold 2>/dev/null || true)"
      _UI_DIM="$(tput dim 2>/dev/null || true)"
      _UI_RED="$(tput setaf 1 2>/dev/null || true)"
      _UI_GREEN="$(tput setaf 2 2>/dev/null || true)"
      _UI_YELLOW="$(tput setaf 3 2>/dev/null || true)"
      _UI_CYAN="$(tput setaf 6 2>/dev/null || true)"
      _UI_RESET="$(tput sgr0 2>/dev/null || true)"
    fi
  fi
  return 0
}

# Starts a run: a scratch directory for the warnings the steps raise (DOTFILES_WARNINGS_FILE is what they find it by), removed by ui_cleanup.
# It fails when the directory cannot be made, since the summary would say "no warnings" without it.
ui_begin() {
  _UI_DIR="$(mktemp -d 2>/dev/null)" || return 1
  _UI_WARNINGS="$_UI_DIR/warnings"
  : >"$_UI_WARNINGS"
  export DOTFILES_WARNINGS_FILE="$_UI_WARNINGS"
  return 0
}

ui_cleanup() {
  if [ -n "$_UI_DIR" ]; then
    rm -rf "$_UI_DIR"
  fi
  return 0
}

_ui_warning_count() {
  if [ -n "$_UI_WARNINGS" ] && [ -f "$_UI_WARNINGS" ]; then
    awk 'END { print NR }' "$_UI_WARNINGS"
  else
    echo 0
  fi
}

# One line per fact: ui_banner <title> <label> <value> [<label> <value>]...
# An empty label with a value continues the row above, and an empty label with no value is a blank line. A row with an empty value is left out.
ui_banner() {
  local title="$1" label value
  shift
  _ui_init

  printf '%s%s%s\n' "$_UI_CYAN$_UI_BOLD" "$title" "$_UI_RESET"
  while [ "$#" -ge 2 ]; do
    label="$1"
    value="$2"
    shift 2
    if [ -z "$label" ] && [ -z "$value" ]; then
      echo
    elif [ -n "$value" ]; then
      printf '  %s%-9s%s %s\n' "$_UI_DIM" "$label" "$_UI_RESET" "$value"
    fi
  done
  return 0
}

# Opens a step: a blank line, then "==> <name>  <what it does>". Its time and the warnings it raises are counted from here.
ui_step() {
  _ui_init
  _UI_STEP="$1"
  _UI_STEP_START=$SECONDS
  _UI_STEP_WARNINGS="$(_ui_warning_count)"
  if [ -z "$_UI_RUN_START" ]; then
    _UI_RUN_START=$SECONDS
  fi

  printf '\n%s==>%s %s%-12s%s %s%s%s\n' "$_UI_CYAN$_UI_BOLD" "$_UI_RESET" "$_UI_BOLD" "$1" "$_UI_RESET" "$_UI_DIM" "${2:-}" "$_UI_RESET"
  return 0
}

# One status line: _ui_status <colour> <word> <text>
_ui_status() {
  _ui_init
  printf '  %s%-4s%s  %s\n' "$1" "$2" "$_UI_RESET" "$3"
}

# Records the open step's outcome with its seconds: _ui_close <outcome> <detail>. The detail shows in the summary table.
_ui_close() {
  local secs=0

  if [ -n "$_UI_STEP" ]; then
    secs=$((SECONDS - _UI_STEP_START))
    _UI_RESULTS="$_UI_RESULTS$_UI_STEP"$'\t'"$1"$'\t'"$secs"$'\t'"${2:-}"$'\n'
    _UI_STEP=""
  fi
  return 0
}

# Closes the step as done. When the step raised warnings on its way, it closes as a warn instead, the warnings being listed in the summary.
ui_ok() {
  local secs warnings

  secs=$((SECONDS - _UI_STEP_START))
  warnings=$(($(_ui_warning_count) - _UI_STEP_WARNINGS))
  if [ "$warnings" -gt 0 ]; then
    _ui_status "$_UI_YELLOW" warn "done in ${secs}s, with $warnings warning(s) above"
    _ui_close warn
  else
    _ui_status "$_UI_GREEN" ok "done in ${secs}s"
    _ui_close ok
  fi
  return 0
}

# Closes the step as left alone, and says why: a skip variable, --only, nothing to do.
ui_skip() {
  _ui_status "$_UI_DIM" skip "$1"
  _ui_close skip "$1"
  return 0
}

# Closes the step with a warning, and adds the message to the ones the summary lists: an optional step that did not work.
ui_warn() {
  _ui_status "$_UI_YELLOW" warn "$1"
  if [ -n "$_UI_WARNINGS" ]; then
    printf '%s\n' "$1" >>"$_UI_WARNINGS"
  fi
  _ui_close warn
  return 0
}

# Closes the step as failed. install.sh stops after it, with the summary.
ui_fail() {
  _ui_status "$_UI_RED$_UI_BOLD" fail "$1"
  _ui_close fail "$1"
  return 0
}

# A remark on its own line, outside the outcome of a step.
ui_note() {
  _ui_init
  _ui_status "$_UI_CYAN" note "$1"
  return 0
}

# What a finished step came to (ok, skip, warn or fail), nothing when it did not run.
ui_outcome() {
  local name outcome

  while IFS=$'\t' read -r name outcome _; do
    if [ "$name" = "$1" ]; then
      echo "$outcome"
      return 0
    fi
  done <<<"$_UI_RESULTS"
  return 0
}

# Asks a yes or no question and succeeds for yes: ui_confirm <question> [<seconds>]. An empty answer, or none in the seconds (15 by default), is a yes.
ui_confirm() {
  local seconds="${2:-15}" reply="" status=0

  _ui_init
  read -r -t "$seconds" -p "$1 [Y/n] " reply || status=$?
  if [ "$status" -gt 128 ]; then
    echo
    ui_note "no answer in ${seconds}s, going on"
    return 0
  fi
  if [ "$status" -ne 0 ]; then
    echo
    return 1
  fi

  reply="$(printf '%s' "$reply" | tr '[:upper:]' '[:lower:]')"
  case "$reply" in
    "" | y | yes) return 0 ;;
  esac
  return 1
}

# The end of the run: every step with its outcome and seconds, the warnings word for word (or that there are none), then what is left for the
# person to do, one argument each.
ui_summary() {
  local name outcome secs detail line colour count

  _ui_init
  count="$(_ui_warning_count)"

  printf '\n%s==>%s %ssummary%s\n\n' "$_UI_CYAN$_UI_BOLD" "$_UI_RESET" "$_UI_BOLD" "$_UI_RESET"
  printf '  %s%-12s %-8s %7s%s\n' "$_UI_DIM" step outcome seconds "$_UI_RESET"
  while IFS=$'\t' read -r name outcome secs detail; do
    [ -n "$name" ] || continue
    case "$outcome" in
      ok) colour="$_UI_GREEN" ;;
      skip) colour="$_UI_DIM" ;;
      warn) colour="$_UI_YELLOW" ;;
      *) colour="$_UI_RED$_UI_BOLD" ;;
    esac
    printf '  %-12s %s%-8s%s %7s' "$name" "$colour" "$outcome" "$_UI_RESET" "$secs"
    if [ -n "$detail" ]; then
      printf '  %s%s%s' "$_UI_DIM" "$detail" "$_UI_RESET"
    fi
    echo
  done <<<"$_UI_RESULTS"
  printf '  %s%-12s %-8s %7s%s\n' "$_UI_DIM" total "" "$((SECONDS - ${_UI_RUN_START:-$SECONDS}))" "$_UI_RESET"

  echo
  if [ "$count" -eq 0 ]; then
    echo "  no warnings"
  else
    while IFS= read -r line; do
      _ui_status "$_UI_YELLOW" warn "$line"
    done <"$_UI_WARNINGS"
  fi

  if [ "$#" -gt 0 ]; then
    echo
    for line in "$@"; do
      _ui_status "$_UI_CYAN" note "$line"
    done
  fi
  return 0
}

# For an install step, not for install.sh: prints "warning: <message>" to stderr, as the steps always have, and adds the message to the file
# install.sh reads for its summary. That file is named by DOTFILES_WARNINGS_FILE, which only install.sh sets, so a step run on its own just prints.
report_warning() {
  echo "warning: $*" >&2
  if [ -n "${DOTFILES_WARNINGS_FILE:-}" ]; then
    printf '%s\n' "$*" >>"$DOTFILES_WARNINGS_FILE" 2>/dev/null || true
  fi
  return 0
}
