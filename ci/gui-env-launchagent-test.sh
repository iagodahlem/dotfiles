#!/usr/bin/env bash
# Checks that scripts/gui-env-launchagent.sh resolves CLAUDE_CONFIG_DIR and CODEX_HOME the way a zsh login shell
# would, local.zshenv included: .zshenv only sources config/zsh/local.zshenv under zsh itself, so a machine whose
# local.zshenv unsets a var (a work machine's `unset CLAUDE_CONFIG_DIR`, so the company's Claude Code keeps the
# stock ~/.claude, see AGENTS.md) must still see that var cleared in launchd, not pinned to its XDG default.
# A fake launchctl on PATH logs its own arguments instead of touching the real one.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "gui-env-launchagent-test: $*" >&2
  exit 1
}

command -v zsh >/dev/null 2>&1 || fail "zsh required for this test"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/bin"
cat > "$work/bin/launchctl" <<'FAKE'
#!/usr/bin/env bash
echo "launchctl $*" >> "$LAUNCHCTL_LOG"
FAKE
chmod +x "$work/bin/launchctl"

# One case's scratch HOME (its own .zshenv, linked to the tracked one) and DOTFILES (so config/zsh/local.zshenv,
# which .zshenv reads from $DOTFILES_ZSH, is this case's own file and never the real checkout's gitignored one).
run_case() {
  local name="$1" local_zshenv_line="${2:-}"
  local home="$work/$name/home" dots="$work/$name/dotfiles" log="$work/$name.log"

  mkdir -p "$home" "$dots/config/zsh"
  ln -s "$ROOT_DIR/config/zsh/.zshenv" "$home/.zshenv"
  if [ -n "$local_zshenv_line" ]; then
    printf '%s\n' "$local_zshenv_line" > "$dots/config/zsh/local.zshenv"
  fi

  : > "$log"
  env -i HOME="$home" DOTFILES="$dots" PATH="$work/bin:/usr/bin:/bin" LAUNCHCTL_LOG="$log" \
    bash "$ROOT_DIR/scripts/gui-env-launchagent.sh" || fail "$name: gui-env-launchagent.sh exited non-zero"

  cat "$log"
}

# Case 1: local.zshenv unsets CLAUDE_CONFIG_DIR, so launchd must get unsetenv for it, not setenv to the XDG path.
output="$(run_case unset 'unset CLAUDE_CONFIG_DIR')"
echo "$output" | grep -qx 'launchctl unsetenv CLAUDE_CONFIG_DIR' || fail "unset case: expected 'launchctl unsetenv CLAUDE_CONFIG_DIR', got:
$output"
echo "$output" | grep -q '^launchctl setenv CODEX_HOME ' || fail "unset case: expected CODEX_HOME to still be setenv'd, got:
$output"
echo "$output" | grep -q '^launchctl setenv CLAUDE_CONFIG_DIR ' && fail "unset case: CLAUDE_CONFIG_DIR must not be setenv'd, got:
$output"

# Case 2: no local.zshenv override, so launchd must get setenv to the XDG path .zshenv computes for both vars.
output="$(run_case set)"
echo "$output" | grep -q '^launchctl setenv CLAUDE_CONFIG_DIR .*/\.config/claude$' || fail "set case: expected CLAUDE_CONFIG_DIR setenv'd to its XDG path, got:
$output"
echo "$output" | grep -q '^launchctl setenv CODEX_HOME .*/\.local/share/codex$' || fail "set case: expected CODEX_HOME setenv'd to its XDG path, got:
$output"
echo "$output" | grep -q 'unsetenv' && fail "set case: nothing should be unsetenv'd, got:
$output"

echo "gui-env-launchagent-test ok"
