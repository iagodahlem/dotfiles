#!/usr/bin/env bash
# The one public entrypoint: runs the install steps in order. See --help.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/scripts/utils/os.sh"
source "$ROOT_DIR/scripts/utils/host.sh"
source "$ROOT_DIR/scripts/utils/dry-run.sh"
source "$ROOT_DIR/scripts/utils/ui.sh"
OS_ID="$(os_id)"

# One row per step, in run order: the name, the variable that skips it, its script and what it does (the text after the name in its header).
# A script of "-" is the OS defaults script for this OS, see os_defaults_script, and "@host" is the install.sh of this machine's host overlay, see host_script.
STEPS='
private      DOTFILES_SKIP_PRIVATE      scripts/install-private.sh   the private overlays repo, cloned to DOTFILES_PRIVATE or pulled there
packages     DOTFILES_SKIP_PACKAGES     scripts/install-packages.sh  packages from packages/ (brew bundle, apt, pacman)
dotfiles     DOTFILES_SKIP_DOTFILES     scripts/install-dotfiles.sh  link config/ into place from config/links, after clearing the older layout
shell        DOTFILES_SKIP_SHELL        scripts/install-shell.sh     Oh My Zsh, Powerlevel10k, the zsh plugins and tpm
mise         DOTFILES_SKIP_MISE         scripts/install-mise.sh      mise, node, pnpm and bun
ai-clis      DOTFILES_SKIP_AI_CLIS      scripts/install-ai-clis.sh   claude, codex and gemini
nvim         DOTFILES_SKIP_NVIM         scripts/install-nvim.sh      the LazyVim plugin sync
os-defaults  DOTFILES_SKIP_OS_DEFAULTS  -                            the OS defaults (settings on macOS, login shell and docker group on Linux)
host         DOTFILES_SKIP_HOST         @host                        what this machine needs beyond the shared steps, the install.sh of its host overlay
'

# the private overlays repo, mise, the AI CLIs, the nvim plugins and the host hook come from remote sources: a failure warns and the rest of the install carries on
OPTIONAL_STEPS=" private mise ai-clis nvim host "

usage() {
  local name var desc

  cat <<'EOF'
Usage: install.sh [--only <step>]... [--dry-run] [--yes]

Steps, in the order they run, with the variable that skips each one:

EOF
  while read -r -u 3 name var _ desc; do
    [ -n "$name" ] || continue
    printf '  %-12s %-28s %s\n' "$name" "$var=1" "$desc"
  done 3<<<"$STEPS"
  cat <<'EOF'

Options:

  --only <step>  run just this step, repeat it for more; the skip variables are not consulted
  --dry-run      print what each step would do and change nothing (DOTFILES_DRY_RUN=1 does the same)
  --yes          do not ask before a real run (DOTFILES_YES=1 does the same)
  -h, --help     print this help

A real run starts with a banner (the host, the OS, the checkout, the steps that run and the ones that do not) and, from a terminal, asks "Run these steps? [Y/n]", taking yes after 15 seconds without an answer.
A dry run, and a run with no terminal (CI, a container build), never asks. Each step then prints one "==>" header, its own output and a line that says how it went (ok, skip, warn or fail), and the run ends with a summary of the steps, their seconds and the warnings.
Colour and bold only show on a terminal; NO_COLOR=1 turns them off, and a log or a pipe gets plain text.

private, mise, ai-clis, nvim and host fetch from the network, so a failure in one of them warns and the run carries on.
private runs first, so the overlay of this machine is there for the steps after it. It clones DOTFILES_PRIVATE_REPO (ssh form) to DOTFILES_PRIVATE, ~/.machines by default, and does nothing while that is unset.
DOTFILES_HOST names this machine, the short hostname by default. Its overlay is <DOTFILES_PRIVATE>/<name>/dotfiles/ when that exists, else overlays/host/<name>/:
its Brewfile on macOS, its git config, and its install.sh for the host step.
A dry run reports the machine as it is now: a step that depends on an earlier one (mise on the packages, nvim on the dotfiles links) reports what it finds today.
EOF
}

is_step() {
  local name

  while read -r -u 3 name _; do
    if [ "$name" = "$1" ]; then
      return 0
    fi
  done 3<<<"$STEPS"
  return 1
}

os_defaults_script() {
  case "$OS_ID" in
    macos) echo os/macos.sh ;;
    ubuntu | debian | raspbian) echo os/ubuntu.sh ;;
    arch) echo os/arch.sh ;;
  esac
}

# The install.sh in this machine's host overlay, or nothing when it has none: see host_overlay_dir for where the overlay is looked for.
host_script() {
  local dir
  dir="$(host_overlay_dir "$ROOT_DIR")"

  if [ -n "$dir" ] && [ -f "$dir/install.sh" ]; then
    echo "$dir/install.sh"
  fi
}

# Why a step is not run, nothing when it is: it is not among the --only steps, or its skip variable is set.
# --only names a step on purpose, so its skip variable does not apply, and with --only the one reason left is "not named".
step_skip_reason() {
  local name="$1" var="$2"

  if [ -n "$ONLY" ]; then
    case " $ONLY" in
      *" $name "*) ;;
      *) echo "not named by --only" ;;
    esac
  elif [ "${!var:-0}" = "1" ]; then
    echo "$var=1"
  fi
  return 0
}

# The banner: the machine, the checkout and mode, then the steps that run and the ones that do not, and why.
print_banner() {
  local mode="real" overlay overlay_label="" name var reason
  local steps="" not_named="" first_skip=1
  local rows=()

  if [ "$DRY_RUN" = "1" ]; then
    mode="dry run, nothing is installed or changed"
  fi

  overlay="$(host_overlay_dir "$ROOT_DIR")"
  if [ -n "$overlay" ]; then
    case "$overlay" in
      "$(private_dir)"/*) overlay_label="$(display_path "$overlay") (private)" ;;
      *) overlay_label="$(display_path "$overlay") (in the checkout)" ;;
    esac
  fi

  while read -r -u 3 name var _; do
    [ -n "$name" ] || continue
    reason="$(step_skip_reason "$name" "$var")"
    if [ -z "$reason" ]; then
      steps="$steps $name"
    elif [ -n "$ONLY" ]; then
      not_named="$not_named $name"
    else
      if [ "$first_skip" = 1 ]; then
        rows+=(skipped "$(printf '%-12s %s' "$name" "$reason")")
        first_skip=0
      else
        rows+=("" "$(printf '%-12s %s' "$name" "$reason")")
      fi
    fi
  done 3<<<"$STEPS"

  ui_banner "dotfiles installer" \
    host "$(host_id)" \
    os "$OS_ID" \
    checkout "$(display_path "$ROOT_DIR")" \
    overlay "$overlay_label" \
    mode "$mode" \
    "" "" \
    steps "${steps# }" \
    skipped "${not_named:+${not_named# } (not named by --only)}" \
    ${rows[@]+"${rows[@]}"}
}

# The end of the run: the summary, and what is left for the person to do when it applies.
finish() {
  local git_local="$ROOT_DIR/config/git/local"

  set --
  case "$(ui_outcome dotfiles)" in
    ok | warn)
      if [ ! -e "$git_local" ]; then
        set -- "$@" "config/git/local is missing, so commits here use the default identity: copy config/git/local.example to it and set the email for this machine (docs/new-mac.md)"
      fi
      ;;
  esac

  # a dry run changes nothing, so it has nothing to log out of or to grant
  if [ "$DRY_RUN" != "1" ] && [ "$OS_ID" = "macos" ]; then
    case "$(ui_outcome os-defaults)" in
      ok | warn) set -- "$@" "log out and back in for the key repeat setting to apply" ;;
    esac
    if [ -z "$KARABINER_BEFORE" ] && [ -d "$KARABINER_APP" ]; then
      set -- "$@" "Karabiner-Elements needs its permissions granted in System Settings on the first launch (docs/new-mac.md)"
    fi
  fi

  ui_summary "$@"
}

DRY_RUN="${DOTFILES_DRY_RUN:-0}"
YES="${DOTFILES_YES:-0}"
ONLY=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --yes)
      YES=1
      ;;
    --only)
      if [ "$#" -lt 2 ]; then
        echo "install.sh: --only needs a step name" >&2
        exit 2
      fi
      if ! is_step "$2"; then
        echo "install.sh: unknown step '$2', run install.sh --help for the list" >&2
        exit 2
      fi
      ONLY="$ONLY$2 "
      shift
      ;;
    *)
      echo "install.sh: unknown argument '$1'" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

# every step reads this, see scripts/utils/dry-run.sh
export DOTFILES_DRY_RUN="$DRY_RUN"

# Karabiner-Elements asks for its permissions on its first launch, so only a run that installs it has that to say
KARABINER_APP="/Applications/Karabiner-Elements.app"
KARABINER_BEFORE=""
if [ -d "$KARABINER_APP" ]; then
  KARABINER_BEFORE=1
fi

ui_begin || { echo "install.sh: could not make a temporary directory" >&2; exit 1; }
trap ui_cleanup EXIT

print_banner

# a real run asks once, from a terminal: CI and container builds have none, and --yes or DOTFILES_YES=1 is for a person who does not want the question
if [ "$DRY_RUN" != "1" ] && [ "$YES" != "1" ] && [ -t 0 ]; then
  echo
  if ! ui_confirm "Run these steps?" 15; then
    echo "Stopped before the first step, nothing was changed."
    exit 1
  fi
fi

while read -r -u 3 name var script desc; do
  [ -n "$name" ] || continue

  reason="$(step_skip_reason "$name" "$var")"
  # a step that --only leaves out gets no header
  if [ -n "$ONLY" ] && [ -n "$reason" ]; then
    continue
  fi

  ui_step "$name" "$desc"

  if [ -n "$reason" ]; then
    ui_skip "$reason"
    continue
  fi

  if [ "$script" = "-" ]; then
    script="$(os_defaults_script)"
    if [ -z "$script" ]; then
      ui_skip "no defaults for $OS_ID"
      continue
    fi
  elif [ "$script" = "@host" ]; then
    script="$(host_script)"
    if [ -z "$script" ]; then
      ui_skip "no install.sh in the host overlay of $(host_id)"
      continue
    fi
    echo "running ${script#"$ROOT_DIR"/}"
  fi

  case "$script" in
    /*) script_path="$script" ;;
    *) script_path="$ROOT_DIR/$script" ;;
  esac

  status=0
  "$script_path" || status=$?

  if [ "$status" -eq 0 ]; then
    ui_ok
    continue
  fi

  case "$OPTIONAL_STEPS" in
    *" $name "*)
      ui_warn "${script#"$ROOT_DIR"/} failed, rerun it on its own once the cause is fixed"
      ;;
    *)
      # the run stops here with the status of the step, as it always has
      ui_fail "${script#"$ROOT_DIR"/} exited with status $status"
      finish
      exit "$status"
      ;;
  esac
done 3<<<"$STEPS"

finish
