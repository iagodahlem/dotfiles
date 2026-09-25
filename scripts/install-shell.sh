#!/usr/bin/env bash
# Clones oh-my-zsh and tpm (the tmux plugin manager), each at the default branch, unpinned.
# Rerunning this script fast-forwards an existing clone, so it is also the updater (oh-my-zsh's own updater is off in .zshrc).
# Powerlevel10k and the two zsh plugins are cloned only where the OS has no package for them, see the package lists.
# Where they go comes from config/zsh/.zshenv ($ZSH, $ZSH_CUSTOM and $TMUX_PLUGIN_MANAGER_PATH), so nothing here needs an interactive shell.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MINIMAL="${DOTFILES_CONTAINER_MINIMAL:-0}"

if [ "$MINIMAL" = "1" ]; then
  exit 0
fi

# shellcheck source=/dev/null
source "$ROOT_DIR/config/zsh/.zshenv"
source "$ROOT_DIR/scripts/utils/paths.sh"

setup_tool_path

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

# Homebrew's prefix, empty without Homebrew. The shell start reads HOMEBREW_PREFIX, which shellenv sets, and an installer has not run it.
brew_prefix() {
  if [ -n "${HOMEBREW_PREFIX:-}" ]; then
    echo "$HOMEBREW_PREFIX"
  elif command -v brew >/dev/null 2>&1; then
    brew --prefix 2>/dev/null || true
  fi
}

# Whether a package provides the zsh add-on. The paths are the package ones from find_zsh_addon in config/zsh/.bootstrap, keep the two in step.
packaged() {
  local name="$1"
  local prefix path
  local candidates=()
  prefix="$(brew_prefix)"

  case "$name" in
    powerlevel10k)
      # Homebrew and the AUR only: Debian, Ubuntu and the Arch repositories have no package
      [ -z "$prefix" ] || candidates+=("$prefix/share/powerlevel10k/powerlevel10k.zsh-theme")
      candidates+=(/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme)
      ;;
    *)
      [ -z "$prefix" ] || candidates+=("$prefix/share/$name/$name.zsh")
      candidates+=("/usr/share/zsh/plugins/$name/$name.zsh" "/usr/share/$name/$name.zsh")
      ;;
  esac

  for path in "${candidates[@]}"; do
    [ -r "$path" ] && return 0
  done
  return 1
}

clone_unless_packaged() {
  local name="$1"
  local url="$2"
  local dest="$3"

  if packaged "$name"; then
    return 0
  fi
  clone_or_pull "$url" "$dest"
}

clone_or_pull https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
clone_unless_packaged powerlevel10k https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
clone_unless_packaged zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_unless_packaged zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_pull https://github.com/tmux-plugins/tpm.git "$TMUX_PLUGIN_MANAGER_PATH/tpm"
