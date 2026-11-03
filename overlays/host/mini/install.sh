#!/usr/bin/env bash
# The installer's host step for the mini: AC-power settings so mosh keeps working (see README.md in this
# directory), plus the Rancher Desktop housekeeping only this machine needs, since the shared dotfiles stay
# Rancher-agnostic. Every check below is idempotent and diff-first: read the current state, change it only
# when it differs, and DOTFILES_DRY_RUN=1 (scripts/utils/dry-run.sh's run) prints what would change and
# touches nothing.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$ROOT_DIR/scripts/utils/dry-run.sh"
source "$ROOT_DIR/scripts/utils/ui.sh"
source "$ROOT_DIR/scripts/utils/zshenv.sh"
source "$ROOT_DIR/scripts/utils/pmset.sh"

if ! command -v pmset > /dev/null 2>&1; then
  echo "pmset not found, this is not macOS: nothing to do"
  exit 0
fi

# How long rdctl and docker info get to answer before they count as stuck, below.
RDCTL_TIMEOUT_SECS=5
DOCKER_INFO_TIMEOUT_SECS=5

# Runs a command with a time limit, so a backend that accepts a connection and never answers (rdctl, docker info
# against a stuck VM) cannot hang the rest of the housekeeping. Bash 3.2 (the one macOS ships) has no "wait -n",
# so this races a background watcher against the command itself instead of shelling out to GNU coreutils' timeout,
# which this machine does not have.
with_timeout() {
  local secs="$1" pid watcher status
  shift

  "$@" &
  pid=$!

  (
    sleep "$secs"
    kill -TERM "$pid" 2>/dev/null
  ) &
  watcher=$!

  if wait "$pid" 2>/dev/null; then
    status=0
  else
    status=$?
  fi

  kill "$watcher" 2>/dev/null
  wait "$watcher" 2>/dev/null
  return "$status"
}

# Rancher Desktop only runs on this machine, so the shared dotfiles stay Rancher-agnostic and this installer owns
# ~/.rd/bin's place on PATH itself, through /etc/paths.d rather than a shell rcfile: path_helper (run from
# /etc/zprofile) folds every file in /etc/paths.d into PATH ahead of anything a login shell adds on its own, for
# every login shell this machine actually uses (a new Terminal window, a tmux window: tmux starts one since
# default-command is unset in config/tmux/tmux.conf, an interactive ssh session), though not the non-login,
# non-interactive shell ssh runs for a single command (mosh-server, scp, git over ssh), which reads ~/.zshenv only,
# same gap the Homebrew PATH prepend there documents. Homebrew's own /opt/homebrew/bin travels the same way (see
# /etc/paths.d/homebrew on this machine), and config/brew/init.zsh's full `brew shellenv` still re-prepends it ahead
# of this at the interactive-shell stage, so this never ends up before Homebrew's own bins.
rancher_path_paths_d() {
  local rd_bin="$HOME/.rd/bin"
  local dst="/etc/paths.d/rancher-desktop"
  local current=""

  if [ ! -d "$rd_bin" ]; then
    echo "rancher desktop: ~/.rd/bin not found, $dst left alone"
    return 0
  fi

  if [ -f "$dst" ]; then
    current="$(cat "$dst")"
  fi

  if [ "$current" = "$rd_bin" ]; then
    echo "$dst already $rd_bin"
    return 0
  fi

  echo "$dst: ${current:-missing} -> $rd_bin"
  run sudo tee "$dst" <<< "$rd_bin" || report_warning "sudo tee $dst failed, run it by hand"
}

# Rancher Desktop also defaults to managing PATH itself ("rcfiles"): writing its own block into shell rc files
# (below) on every start, which would fight the /etc/paths.d entry above and litter rc files this machine does not
# read. Settings live in settings.json, at ~/Library/Preferences/rancher-desktop on macOS (not ~/Library/Application
# Support, which only holds the VM and its images), read with jq rather than `rdctl list-settings` so this can
# report the current value even while the backend is not running; only the actual change needs a live backend,
# since rdctl set talks to it over its local API.
rancher_path_manual() {
  local rdctl="$HOME/.rd/bin/rdctl"
  local settings_file="$HOME/Library/Preferences/rancher-desktop/settings.json"
  local have

  if [ ! -x "$rdctl" ]; then
    echo "rancher desktop: ~/.rd/bin/rdctl not found, path management left alone"
    return 0
  fi

  if [ ! -f "$settings_file" ]; then
    echo "rancher desktop: no settings.json yet, path management left alone"
    return 0
  fi

  if ! have="$(jq -r '.application.pathManagementStrategy // "unset"' "$settings_file" 2>/dev/null)"; then
    report_warning "rancher desktop: $settings_file is not valid JSON, path management left alone"
    return 0
  fi

  if [ "$have" = "manual" ]; then
    echo "rancher desktop: path management already manual"
  elif ! with_timeout "$RDCTL_TIMEOUT_SECS" "$rdctl" list-settings > /dev/null 2>&1; then
    echo "rancher desktop: not running or not responding, path management still $have (rerun once it is open)"
  elif is_dry_run; then
    run "$rdctl" set --application.path-management-strategy=manual
  else
    echo "rancher desktop: path management $have -> manual"
    if ! with_timeout "$RDCTL_TIMEOUT_SECS" run "$rdctl" set --application.path-management-strategy=manual; then
      report_warning "rancher desktop: rdctl set did not finish in ${RDCTL_TIMEOUT_SECS}s, path management still $have"
    fi
  fi
}

# With path management on, Rancher writes a "### MANAGED BY RANCHER DESKTOP START/END (DO NOT EDIT)" block straight
# into ~/.zshrc, ~/.bashrc, ~/.bash_profile, ~/.cshrc and ~/.tcshrc. ~/.zshrc is dead weight once ZDOTDIR is set (zsh
# reads $ZDOTDIR/.zshrc instead, see legacy_leave_reason in scripts/install-dotfiles.sh), and none of the other four
# shells are used here either, so a file holding nothing but that block is backed up and removed, the same
# ".bak.<timestamp>" convention install-dotfiles.sh's safe_link uses. A file with anything else in it is left alone.
remove_dead_rcfiles() {
  local start='### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)'
  local end='### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)'
  local name path body ts

  for name in .zshrc .bashrc .bash_profile .cshrc .tcshrc; do
    path="$HOME/$name"

    if [ ! -f "$path" ] || [ -L "$path" ]; then
      continue
    fi

    if [ ! -r "$path" ]; then
      report_warning "rc file ~/$name is not readable, left alone"
      continue
    fi

    # grep -v exits 1, with no error, when every line is blank (or the file is empty); that is not a failure here.
    body="$(grep -v '^[[:space:]]*$' "$path" || true)"

    case "$body" in
      "")
        echo "rc file ~/$name is empty, nothing to clean up"
        ;;
      "$start"$'\n'*"$end")
        ts="$(date +%Y%m%d%H%M%S)"
        if is_dry_run; then
          run mv "$path" "$path.bak.$ts"
        else
          echo "rc file ~/$name: nothing but Rancher Desktop's managed block, backing up and removing"
          run mv "$path" "$path.bak.$ts"
        fi
        ;;
      *)
        report_warning "rc file ~/$name has content beyond Rancher Desktop's managed block, left alone"
        ;;
    esac
  done
}

# Rancher Desktop's docker talks over ~/.rd/docker.sock, but installing it never points the docker CLI's own context
# at that socket. Create the rancher-desktop context when it is missing, and only switch to it when the current
# context does not answer a bounded `docker --context <name> info` probe (so a working ssh:// or tcp:// context,
# not just a unix socket one, counts as live too), leaving a working OrbStack or Docker Desktop context alone.
# DOCKER_CONFIG is resolved through resolve_zshenv_vars (see scripts/utils/zshenv.sh), the same way a zsh login
# shell would see it, so this reads and writes the context config/zsh/.zshenv moved, not plain ~/.docker.
docker_context_rancher() {
  local sock="$HOME/.rd/docker.sock"
  local current line docker_config

  if [ ! -S "$sock" ]; then
    echo "docker: no ~/.rd/docker.sock, rancher-desktop context left alone"
    return 0
  fi

  if ! command -v docker > /dev/null 2>&1; then
    echo "docker: cli not found, rancher-desktop context left alone"
    return 0
  fi

  if command -v zsh > /dev/null 2>&1; then
    docker_config=""
    while IFS= read -r line; do
      case "$line" in
        DOCKER_CONFIG=*) docker_config="${line#DOCKER_CONFIG=}" ;;
      esac
    done < <(resolve_zshenv_vars DOCKER_CONFIG)
    if [ -n "$docker_config" ] && [ "$docker_config" != "$ZSHENV_UNSET_MARK" ]; then
      export DOCKER_CONFIG="$docker_config"
    fi
  else
    report_warning "zsh not found, DOCKER_CONFIG not resolved; the docker CLI falls back to its own default (~/.docker)"
  fi

  if docker context inspect rancher-desktop > /dev/null 2>&1; then
    echo "docker: rancher-desktop context already exists"
  else
    echo "docker: creating the rancher-desktop context for $sock"
    run docker context create rancher-desktop --docker "host=unix://$sock"
  fi

  current="$(docker context show 2>/dev/null || echo default)"

  if [ "$current" = "rancher-desktop" ]; then
    echo "docker: rancher-desktop already the current context"
    return 0
  fi

  if docker context inspect "$current" > /dev/null 2>&1 \
    && with_timeout "$DOCKER_INFO_TIMEOUT_SECS" docker --context "$current" info > /dev/null 2>&1; then
    echo "docker: current context $current answers, leaving it current"
    return 0
  fi

  echo "docker: current context $current does not answer, switching to rancher-desktop"
  run docker context use rancher-desktop
}

pmset_ensure -c "AC Power" sleep 0         # never sleep the system, so mosh keeps a machine to talk to
pmset_ensure -c "AC Power" displaysleep 15 # the display still turns off, the machine stays up
pmset_ensure -c "AC Power" womp 1          # "Wake for network access": the sleep proxy can wake it for a TCP connection if it is ever put to sleep by hand
pmset_ensure -c "AC Power" disksleep 0     # no disk spin-down

if is_dry_run; then
  echo "AC power now, nothing changed:"
else
  echo "AC power now:"
fi
pmset_custom_block "AC Power"

rancher_path_paths_d
rancher_path_manual
remove_dead_rcfiles
docker_context_rancher
