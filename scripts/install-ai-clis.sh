#!/usr/bin/env bash
# Installs the AI coding CLIs from their vendors' own installers, on every OS.
# One that is already on PATH is skipped unless --update is given, and a failure does not stop the others.
#   claude  https://docs.anthropic.com/en/docs/claude-code/setup
#   codex   https://github.com/openai/codex (standalone installer from the README)
#   gemini  https://github.com/google-gemini/gemini-cli (npm, run with the node mise installs)
# Run it after install-mise.sh, gemini needs that node.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/scripts/utils/paths.sh"

setup_tool_path

UPDATE=0
case "${1:-}" in
  "") ;;
  --update) UPDATE=1 ;;
  *)
    echo "Usage: install-ai-clis.sh [--update]" >&2
    exit 2
    ;;
esac

failed=()

# succeeds when the CLI still has to be installed
needed() {
  [ "$UPDATE" -eq 1 ] || ! command -v "$1" >/dev/null 2>&1
}

install_claude() {
  if needed claude; then
    curl -fsSL https://claude.ai/install.sh | bash
  else
    echo "claude: already installed"
  fi
}

install_codex() {
  if needed codex; then
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
  else
    echo "codex: already installed"
  fi
}

install_gemini() {
  if ! command -v mise >/dev/null 2>&1; then
    echo "gemini: needs node from mise, run scripts/install-mise.sh first" >&2
    return 1
  fi

  if [ "$UPDATE" -eq 0 ] && mise exec node@lts -- sh -c 'command -v gemini' >/dev/null 2>&1; then
    echo "gemini: already installed"
  else
    mise exec node@lts -- npm install -g @google/gemini-cli
  fi
}

install_claude || failed+=(claude)
install_codex || failed+=(codex)
install_gemini || failed+=(gemini)

if [ "${#failed[@]}" -gt 0 ]; then
  echo "Failed to install: ${failed[*]}. Fix the cause and rerun scripts/install-ai-clis.sh." >&2
  exit 1
fi
