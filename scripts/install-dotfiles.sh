#!/usr/bin/env bash
# Links the tracked config into place from the table in config/links, after clearing the links and files the older layout left in $HOME.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTS="${DOTS:-$HOME/.dotfiles}"
CONFIG_DIR="${DOTFILES_CONFIG_DIR:-$DOTS/config}"
LINKS_FILE="$CONFIG_DIR/links"

source "$ROOT_DIR/scripts/utils/os.sh"
source "$ROOT_DIR/scripts/utils/lists.sh"

safe_link() {
  local src="$1"
  local dst="$2"
  local ts

  if [ ! -e "$src" ]; then
    echo "warning: $src does not exist, not linking $dst" >&2
    return 0
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      return 0
    fi
    rm -f "$dst"
  elif [ -e "$dst" ]; then
    ts="$(date +%Y%m%d%H%M%S)"
    mv "$dst" "${dst}.bak.${ts}"
    echo "backed up ${dst/#"$HOME"/\~} to ${dst/#"$HOME"/\~}.bak.${ts}"
  fi

  ln -s "$src" "$dst"
}

# The files the layout before ~/.config kept in $HOME: a link into the repo is removed, a real file is set aside.
# ~/.gitconfig.override was the untracked identity file, which now lives at ~/.config/git/local.
migrate_legacy() {
  local name path ts
  ts="$(date +%Y%m%d%H%M%S)"

  for name in .zshrc .p10k.zsh .tmux.conf .gitconfig .gitignore_global .gitmessage .tool-versions .gitconfig.override; do
    path="$HOME/$name"

    if [ -L "$path" ]; then
      case "$(readlink "$path")" in
        "$DOTS"/*)
          rm -f "$path"
          echo "migrate: removed the old link ~/$name"
          ;;
      esac
    elif [ -e "$path" ]; then
      if [ "$name" = ".gitconfig.override" ] && [ ! -e "$HOME/.config/git/local" ]; then
        mkdir -p "$HOME/.config/git"
        mv "$path" "$HOME/.config/git/local"
        echo "migrate: moved ~/$name to ~/.config/git/local"
      else
        mv "$path" "$path.bak.$ts"
        echo "migrate: backed up ~/$name to ~/$name.bak.$ts"
      fi
    fi
  done
}

# One safe_link per non-blank line of config/links, skipping the entries for the other OS.
apply_links() {
  local host_os="linux"
  local src dst os

  [ -f "$LINKS_FILE" ] || { echo "Missing $LINKS_FILE" >&2; exit 1; }
  if [ "$(os_id)" = "macos" ]; then
    host_os="macos"
  fi

  while read -r src dst os; do
    case "$os" in
      "" | macos | linux) ;;
      *) echo "warning: $LINKS_FILE: unknown os '$os' for $src, skipping it" >&2; continue ;;
    esac
    if [ -n "$os" ] && [ "$os" != "$host_os" ]; then
      continue
    fi

    case "$dst" in
      \~/*) dst="$HOME/${dst#\~/}" ;;
      *) echo "warning: $LINKS_FILE: target $dst must start with ~/, skipping it" >&2; continue ;;
    esac

    case "$src" in
      */)
        src="${src%/}"
        if [ ! -d "$CONFIG_DIR/$src" ]; then
          echo "warning: $LINKS_FILE: $src/ is not a directory under config/, skipping it" >&2
          continue
        fi
        ;;
      *)
        if [ ! -f "$CONFIG_DIR/$src" ]; then
          echo "warning: $LINKS_FILE: $src is not a file under config/, skipping it" >&2
          continue
        fi
        ;;
    esac

    safe_link "$CONFIG_DIR/$src" "$dst"
  done < <(read_list_items "$LINKS_FILE")
}

migrate_legacy
apply_links

if [ ! -e "$HOME/.config/git/local" ]; then
  echo "No ~/.config/git/local found: commits on this machine use the default identity from config/git/config."
  echo "On a new machine, copy config/git/local.example to ~/.config/git/local and fill in the email for this machine first."
fi
