#!/usr/bin/env bash
# Sets up mise and the runtimes from config/mise/config.toml.
# mise itself comes from the package lists on macOS and Arch, and from https://mise.run on the Debian family.
# There it also installs atuin and procs, which the Debian family has no current package for.
# Run it after install-dotfiles.sh has linked config/mise as ~/.config/mise.
# The go, ruby and rust pins in config.toml are left for an explicit `mise install`.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_TOML="$ROOT_DIR/config/mise/config.toml"
CONF_D="$HOME/.config/mise/conf.d"
# the runtimes this script installs, as a space-padded list
INSTALL_TOOLS=" node pnpm "

source "$ROOT_DIR/scripts/utils/os.sh"
source "$ROOT_DIR/scripts/utils/paths.sh"
source "$ROOT_DIR/scripts/utils/dry-run.sh"

setup_tool_path

is_apt_family() {
  case "$(os_id)" in
    ubuntu|debian|raspbian) return 0 ;;
    *) return 1 ;;
  esac
}

ensure_mise() {
  if command -v mise >/dev/null 2>&1; then
    if is_dry_run; then
      echo "mise: already installed"
    fi
    return 0
  fi

  if is_dry_run; then
    if is_apt_family; then
      echo "mise: not installed, would run: curl -fsSL https://mise.run | sh"
    else
      echo "mise: not installed, on this OS the packages step installs it"
    fi
    return 0
  fi

  if ! is_apt_family; then
    echo "mise is not installed; on this OS it comes from the package lists, run scripts/install-packages.sh first." >&2
    exit 1
  fi

  curl -fsSL https://mise.run | sh
}

apt_gaps_toml() {
  cat <<'TOML'
# Written by scripts/install-mise.sh: tools the Debian family has no current package for.
[tools]
atuin = "latest"
"github:dalance/procs" = "latest"
TOML
}

# a fragment under conf.d instead of `mise use -g`, which would edit the tracked config.toml; through the directory link the fragment
# lands in config/mise/conf.d, which is gitignored
write_apt_gaps() {
  if is_dry_run; then
    echo "would write $(display_path "$CONF_D")/apt-gaps.toml (atuin and procs)"
    return 0
  fi

  mkdir -p "$CONF_D"
  apt_gaps_toml > "$CONF_D/apt-gaps.toml"
}

# the [tools] entries of a mise toml file, one name@version per line
declared_tools() {
  awk '
    /^\[tools\]/ { in_tools = 1; next }
    /^\[/ { in_tools = 0 }
    in_tools && /^[^#[:space:]]/ {
      name = $0
      sub(/[[:space:]]*=.*/, "", name)
      gsub(/"/, "", name)
      version = $0
      sub(/^[^=]*=[[:space:]]*/, "", version)
      sub(/[[:space:]]*#.*$/, "", version)
      gsub(/"/, "", version)
      print name "@" version
    }
  ' "$1"
}

ensure_mise

tools=()
while IFS= read -r tool; do
  case "$INSTALL_TOOLS" in
    *" ${tool%%@*} "*) tools+=("$tool") ;;
  esac
done < <(declared_tools "$CONFIG_TOML")

if is_apt_family; then
  write_apt_gaps
  while IFS= read -r tool; do
    tools+=("$tool")
  done < <(apt_gaps_toml | declared_tools /dev/stdin)
fi

if [ "${#tools[@]}" -gt 0 ]; then
  run mise install "${tools[@]}"
fi

# corepack shims make pnpm resolve even before mise's own pnpm is on PATH
run mise exec node@lts -- corepack enable || echo "warning: corepack enable failed, pnpm still comes from mise" >&2
