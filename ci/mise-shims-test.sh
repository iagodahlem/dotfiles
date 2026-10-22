#!/usr/bin/env bash
# Checks that config/zsh/.zshenv puts mise's shims directory on PATH for the non-interactive, non-login shells
# that never reach config/mise/init.zsh's `mise activate` (an ssh command, an agent subprocess, a git hook): see
# the comment above the mise_shims block in .zshenv. A stub `node` dropped in a fake shims directory stands in
# for a real mise shim, since all that matters here is PATH, not mise itself.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "mise-shims-test: $*" >&2
  exit 1
}

command -v zsh >/dev/null 2>&1 || fail "zsh required for this test"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

make_stub_shim() {
  local dir="$1"
  mkdir -p "$dir"
  cat > "$dir/node" <<'STUB'
#!/usr/bin/env bash
echo stub-node
STUB
  chmod +x "$dir/node"
}

link_zshenv() {
  local home="$1"
  mkdir -p "$home"
  ln -s "$ROOT_DIR/config/zsh/.zshenv" "$home/.zshenv"
}

# Case 1: the default location, $XDG_DATA_HOME/mise/shims, resolved under zsh, the shell other apps actually spawn.
home1="$work/default/home"
link_zshenv "$home1"
make_stub_shim "$home1/.local/share/mise/shims"
out1="$(env -i HOME="$home1" PATH=/usr/bin:/bin zsh -c 'command -v node')" || fail "default case: zsh could not resolve node"
[ "$out1" = "$home1/.local/share/mise/shims/node" ] || fail "default case: expected the shim on PATH, got: $out1"
"$out1" | grep -qx stub-node || fail "default case: resolved node did not run the stub"

# Case 2: MISE_DATA_DIR overrides the default, same as mise itself honours it.
home2="$work/override/home"
link_zshenv "$home2"
make_stub_shim "$work/override/custom-data-dir/shims"
out2="$(env -i HOME="$home2" MISE_DATA_DIR="$work/override/custom-data-dir" PATH=/usr/bin:/bin zsh -c 'command -v node')" \
  || fail "override case: zsh could not resolve node"
[ "$out2" = "$work/override/custom-data-dir/shims/node" ] || fail "override case: expected the overridden shims dir on PATH, got: $out2"

# Case 3: no shims directory at all (mise never installed, or not yet) must not add a dead entry to PATH.
home3="$work/missing/home"
link_zshenv "$home3"
# shellcheck disable=SC2016 # the variable is the child shell's
out3="$(env -i HOME="$home3" PATH=/usr/bin:/bin zsh -c 'echo ":$PATH:"')"
case "$out3" in
  *":$home3/.local/share/mise/shims:"*) fail "missing case: PATH gained a shims entry that does not exist: $out3" ;;
esac

# Case 4: the same resolution, but from bash, since .zshenv is sourced from bash too (scripts/install-shell.sh) and
# stays plain POSIX for that reason.
home4="$work/bash/home"
link_zshenv "$home4"
make_stub_shim "$home4/.local/share/mise/shims"
# shellcheck disable=SC2016 # the variable is the child shell's
out4="$(env -i HOME="$home4" PATH=/usr/bin:/bin bash -c '. "$HOME/.zshenv" && command -v node')" || fail "bash case: bash could not resolve node"
[ "$out4" = "$home4/.local/share/mise/shims/node" ] || fail "bash case: expected the shim on PATH, got: $out4"

echo "mise-shims-test ok"
