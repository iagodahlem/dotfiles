#!/usr/bin/env bash
# Links the tracked config into place from the table in config/links, after clearing the links and files the older layout left in $HOME.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTS="${DOTS:-$HOME/.dotfiles}"
CONFIG_DIR="${DOTFILES_CONFIG_DIR:-$DOTS/config}"
LINKS_FILE="$CONFIG_DIR/links"
GIT_LOCAL="$CONFIG_DIR/git/local"

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
# ~/.gitconfig.override was the untracked identity file, which now lives at config/git/local in the checkout.
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
      if [ "$name" = ".gitconfig.override" ] && [ ! -e "$GIT_LOCAL" ]; then
        mkdir -p "$(dirname "$GIT_LOCAL")"
        mv "$path" "$GIT_LOCAL"
        echo "migrate: moved ~/$name to ${GIT_LOCAL/#"$HOME"/\~}"
      else
        mv "$path" "$path.bak.$ts"
        echo "migrate: backed up ~/$name to ~/$name.bak.$ts"
      fi
    fi
  done
}

# ~/.config/git used to be a real directory of file links with the identity beside them. The identity moves into the checkout, and the
# directory is removed when it holds only our old links so the directory link can take its place. Anything else in it is left for
# safe_link, which backs the whole directory up.
migrate_git_dir() {
  local dir="$HOME/.config/git"
  local old="$dir/local"
  local ts entry name ours=1

  if [ -L "$dir" ] || [ ! -d "$dir" ]; then
    return 0
  fi
  ts="$(date +%Y%m%d%H%M%S)"

  if [ -f "$old" ] && [ ! -L "$old" ]; then
    if [ ! -e "$GIT_LOCAL" ]; then
      mkdir -p "$(dirname "$GIT_LOCAL")"
      mv "$old" "$GIT_LOCAL"
      echo "migrate: moved ~/.config/git/local to ${GIT_LOCAL/#"$HOME"/\~}"
    else
      mv "$old" "$old.bak.$ts"
      echo "migrate: ${GIT_LOCAL/#"$HOME"/\~} already exists, backed up ~/.config/git/local to ~/.config/git/local.bak.$ts"
    fi
  fi

  while IFS= read -r entry; do
    name="$(basename "$entry")"
    case "$name" in
      config | ignore | message)
        if [ -L "$entry" ] && [ "$(readlink "$entry")" = "$CONFIG_DIR/git/$name" ]; then
          continue
        fi
        ;;
    esac
    ours=0
  done < <(find "$dir" -mindepth 1 -maxdepth 1)

  if [ "$ours" = 1 ]; then
    rm -f "$dir/config" "$dir/ignore" "$dir/message"
    rmdir "$dir"
    echo "migrate: removed the old ~/.config/git directory of file links"
  fi
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
migrate_git_dir
apply_links

if [ ! -e "$GIT_LOCAL" ]; then
  echo "No config/git/local found: commits on this machine use the default identity from config/git/config."
  echo "On a new machine, copy config/git/local.example to config/git/local and fill in the email for this machine first."
fi
