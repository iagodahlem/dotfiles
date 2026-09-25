#!/usr/bin/env bash
# Clones oh-my-zsh, Powerlevel10k, the two zsh plugins and tpm (the tmux plugin manager), each at the default branch, unpinned.
# Rerunning this script fast-forwards an existing clone, so it is also the updater (oh-my-zsh's own updater is off in .zshrc).
# Where they go comes from config/zsh/.zshenv ($ZSH, $ZSH_CUSTOM and $TMUX_PLUGIN_MANAGER_PATH), so nothing here needs an interactive shell.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MINIMAL="${DOTFILES_CONTAINER_MINIMAL:-0}"

if [ "$MINIMAL" = "1" ]; then
  exit 0
fi

# shellcheck source=/dev/null
source "$ROOT_DIR/config/zsh/.zshenv"

# An existing clone is fast-forwarded. When that fails (offline, or a clone detached at a commit by an earlier layout) it stays as it is: it still works, just not updated.
clone_or_pull() {
  local url="$1"
  local dest="$2"

  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull -q --ff-only || echo "warning: could not update ${dest#"$HOME"/}, leaving it as it is (delete it and rerun to clone it afresh)" >&2
    return 0
  fi

  echo "Installing ${dest#"$HOME"/}"
  git clone -q --depth 1 "$url" "$dest"
}

clone_or_pull https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
clone_or_pull https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_pull https://github.com/tmux-plugins/tpm.git "$TMUX_PLUGIN_MANAGER_PATH/tpm"
