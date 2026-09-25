#!/usr/bin/env bash
# Sets up mise and the runtimes from config/mise/config.toml.
# mise itself comes from the package lists on macOS and Arch, and from https://mise.run on the Debian family.
# There it also installs atuin and procs, which the Debian family has no current package for.
# Run it after install-dotfiles.sh has linked config/mise/config.toml into ~/.config/mise.
# The go, ruby and rust pins in ~/.tool-versions are left for an explicit `mise install`.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_TOML="$ROOT_DIR/config/mise/config.toml"
CONF_D="$HOME/.config/mise/conf.d"

source "$ROOT_DIR/scripts/utils/os.sh"
source "$ROOT_DIR/scripts/utils/paths.sh"

setup_tool_path

is_apt_family() {
  case "$(os_id)" in
    ubuntu|debian|raspbian) return 0 ;;
    *) return 1 ;;
  esac
}

ensure_mise() {
  command -v mise >/dev/null 2>&1 && return 0

  if ! is_apt_family; then
    echo "mise is not installed; on this OS it comes from the package lists, run scripts/install-packages.sh first." >&2
    exit 1
  fi

  curl -fsSL https://mise.run | sh
}

# a fragment under conf.d instead of `mise use -g`, which would write through the config.toml symlink into the repo
write_apt_gaps() {
  mkdir -p "$CONF_D"
  cat > "$CONF_D/apt-gaps.toml" <<'TOML'
# Written by scripts/install-mise.sh: tools the Debian family has no current package for.
[tools]
atuin = "latest"
"github:dalance/procs" = "latest"
TOML
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
  tools+=("$tool")
done < <(declared_tools "$CONFIG_TOML")

if is_apt_family; then
  write_apt_gaps
  while IFS= read -r tool; do
    tools+=("$tool")
  done < <(declared_tools "$CONF_D/apt-gaps.toml")
fi

if [ "${#tools[@]}" -gt 0 ]; then
  mise install "${tools[@]}"
fi

# corepack shims make pnpm resolve even before mise's own pnpm is on PATH
mise exec node@lts -- corepack enable || echo "warning: corepack enable failed, pnpm still comes from mise" >&2
