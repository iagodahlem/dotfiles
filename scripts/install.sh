#!/usr/bin/env bash
# The one public entrypoint: runs the install steps in order. See --help.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/scripts/utils/os.sh"
source "$ROOT_DIR/scripts/utils/host.sh"
OS_ID="$(os_id)"

# One row per step, in run order: the name, the variable that skips it, its script and what it does.
# A script of "-" is the OS defaults script for this OS, see os_defaults_script, and "@host" is the install.sh of this machine's host overlay, see host_script.
STEPS='
private      DOTFILES_SKIP_PRIVATE      scripts/install-private.sh   the private overlays repo: cloned to DOTFILES_PRIVATE when DOTFILES_PRIVATE_REPO is set, pulled when already there
packages     DOTFILES_SKIP_PACKAGES     scripts/install-packages.sh  packages from packages/ (brew bundle, apt, pacman)
dotfiles     DOTFILES_SKIP_DOTFILES     scripts/install-dotfiles.sh  link config/ into place from config/links, after clearing the older layout
shell        DOTFILES_SKIP_SHELL        scripts/install-shell.sh     Oh My Zsh, Powerlevel10k, the zsh plugins and tpm
mise         DOTFILES_SKIP_MISE         scripts/install-mise.sh      mise, node, pnpm and bun
ai-clis      DOTFILES_SKIP_AI_CLIS      scripts/install-ai-clis.sh   claude, codex and gemini
nvim         DOTFILES_SKIP_NVIM         scripts/install-nvim.sh      the LazyVim plugin sync
os-defaults  DOTFILES_SKIP_OS_DEFAULTS  -                            the OS defaults (settings on macOS, login shell and docker group on Linux)
host         DOTFILES_SKIP_HOST         @host                        what this machine needs beyond the shared steps, the install.sh of its host overlay when there is one
'

# the private overlays repo, mise, the AI CLIs, the nvim plugins and the host hook come from remote sources: a failure warns and the rest of the install carries on
OPTIONAL_STEPS=" private mise ai-clis nvim host "

usage() {
  local name var desc

  cat <<'EOF'
Usage: install.sh [--only <step>]... [--dry-run]

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
  -h, --help     print this help

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

DRY_RUN="${DOTFILES_DRY_RUN:-0}"
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

printed=0
if [ "$DRY_RUN" = "1" ]; then
  echo "Dry run on $OS_ID: nothing is installed or changed."
  printed=1
fi

while read -r -u 3 name var script _; do
  [ -n "$name" ] || continue

  if [ -n "$ONLY" ]; then
    case " $ONLY" in
      *" $name "*) ;;
      *) continue ;;
    esac
  fi

  if [ "$printed" = 1 ]; then
    echo
  fi
  printed=1
  echo "== $name =="

  # --only names a step on purpose, so its skip variable does not apply
  if [ -z "$ONLY" ] && [ "${!var:-0}" = "1" ]; then
    echo "skipped: $var=1"
    continue
  fi

  if [ "$script" = "-" ]; then
    script="$(os_defaults_script)"
    if [ -z "$script" ]; then
      echo "no defaults for $OS_ID"
      continue
    fi
  elif [ "$script" = "@host" ]; then
    script="$(host_script)"
    if [ -z "$script" ]; then
      echo "no install.sh in the host overlay of $(host_id)"
      continue
    fi
    echo "running ${script#"$ROOT_DIR"/}"
  fi

  case "$script" in
    /*) script_path="$script" ;;
    *) script_path="$ROOT_DIR/$script" ;;
  esac

  case "$OPTIONAL_STEPS" in
    *" $name "*)
      "$script_path" || echo "warning: ${script#"$ROOT_DIR"/} failed, rerun it on its own once the cause is fixed" >&2
      ;;
    *)
      "$script_path"
      ;;
  esac
done 3<<<"$STEPS"
