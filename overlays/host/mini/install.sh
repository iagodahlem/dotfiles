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

if ! command -v pmset > /dev/null 2>&1; then
  echo "pmset not found, this is not macOS: nothing to do"
  exit 0
fi

# The AC Power block of `pmset -g custom`: the indented lines after the "AC Power:" header, up to the next header.
ac_block() {
  pmset -g custom | awk '/^[^[:space:]]/ { in_ac = ($0 ~ /^AC Power/); next } in_ac { print }'
}

# The value of one key in the AC block given as $2, empty when the block has no such key.
ac_value() {
  awk -v key="$1" '$1 == key { print $2; exit }' <<< "$2"
}

# Sets one AC key when it is not already at the wanted value.
ensure() {
  local key="$1" want="$2" have

  have="$(ac_value "$key" "$AC")"

  if [ "$have" = "$want" ]; then
    echo "pmset -c $key already $want"
  elif is_dry_run; then
    run sudo pmset -c "$key" "$want"
  else
    echo "pmset -c $key: ${have:-unset} -> $want"
    run sudo pmset -c "$key" "$want"
  fi
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

  if is_dry_run; then
    run sudo tee "$dst" <<< "$rd_bin"
  else
    echo "$dst: ${current:-missing} -> $rd_bin"
    run sudo tee "$dst" <<< "$rd_bin"
  fi
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

  have="$(jq -r '.application.pathManagementStrategy // "unset"' "$settings_file")"

  if [ "$have" = "manual" ]; then
    echo "rancher desktop: path management already manual"
  elif ! "$rdctl" list-settings > /dev/null 2>&1; then
    echo "rancher desktop: not running, path management still $have (rerun once it is open)"
  elif is_dry_run; then
    run "$rdctl" set --application.path-management-strategy=manual
  else
    echo "rancher desktop: path management $have -> manual"
    run "$rdctl" set --application.path-management-strategy=manual
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

    body="$(grep -v '^[[:space:]]*$' "$path")"

    case "$body" in
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
# context's own endpoint socket is not there to answer, so a working OrbStack or Docker Desktop context is left
# alone. DOCKER_CONFIG is resolved through resolve_zshenv_vars (see scripts/utils/zshenv.sh), the same way a zsh
# login shell would see it, so this reads and writes the context config/zsh/.zshenv moved, not plain ~/.docker.
docker_context_rancher() {
  local sock="$HOME/.rd/docker.sock"
  local current endpoint line docker_config

  if [ ! -S "$sock" ]; then
    echo "docker: no ~/.rd/docker.sock, rancher-desktop context left alone"
    return 0
  fi

  if ! command -v docker > /dev/null 2>&1; then
    echo "docker: cli not found, rancher-desktop context left alone"
    return 0
  fi

  if command -v zsh > /dev/null 2>&1; then
    line="$(resolve_zshenv_vars DOCKER_CONFIG)"
    docker_config="${line#DOCKER_CONFIG=}"
    if [ "$docker_config" != "$ZSHENV_UNSET_MARK" ]; then
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

  endpoint="$(docker context inspect "$current" --format '{{ .Endpoints.docker.Host }}' 2>/dev/null || true)"
  endpoint="${endpoint#unix://}"

  if [ -n "$endpoint" ] && [ -S "$endpoint" ]; then
    echo "docker: current context $current's endpoint is live, leaving it current"
    return 0
  fi

  echo "docker: current context $current has no live endpoint, switching to rancher-desktop"
  run docker context use rancher-desktop
}

AC="$(ac_block)"

ensure sleep 0         # never sleep the system, so mosh keeps a machine to talk to
ensure displaysleep 15 # the display still turns off, the machine stays up
ensure womp 1          # "Wake for network access": the sleep proxy can wake it for a TCP connection if it is ever put to sleep by hand
ensure disksleep 0     # no disk spin-down

if is_dry_run; then
  echo "AC power now, nothing changed:"
else
  echo "AC power now:"
fi
ac_block

rancher_path_paths_d
rancher_path_manual
remove_dead_rcfiles
docker_context_rancher
