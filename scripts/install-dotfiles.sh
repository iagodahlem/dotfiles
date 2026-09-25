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
source "$ROOT_DIR/scripts/utils/dry-run.sh"

# Dry run only: how many migration actions it has reported, so it can say when there are none, and the directories those actions would
# remove (one per line), so that the link report after them sees the directory gone instead of in the way.
MIGRATIONS=0
WOULD_REMOVE=$'\n'

# A dry run's report of one migration action: a path relative to $HOME, and what would happen to it.
would_migrate() {
  MIGRATIONS=$((MIGRATIONS + 1))
  echo "migrate ~/$1: $2"
}

# What is at a link's target: correct (the link we want), link (a link to somewhere else), real (a file or directory) or missing.
link_state() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      echo correct
    else
      echo link
    fi
  elif [ -e "$dst" ]; then
    case "$WOULD_REMOVE" in
      *$'\n'"$dst"$'\n'*) echo missing ;;
      *) echo real ;;
    esac
  else
    echo missing
  fi
}

safe_link() {
  local src="$1"
  local dst="$2"
  local ts state

  if [ ! -e "$src" ]; then
    echo "warning: $src does not exist, not linking $dst" >&2
    return 0
  fi

  state="$(link_state "$src" "$dst")"

  if is_dry_run; then
    case "$state" in
      correct) state="correct" ;;
      link) state="links to $(readlink "$dst"), to replace" ;;
      real) state="real $([ -d "$dst" ] && echo directory || echo file) to back up" ;;
      missing) state="missing, to create" ;;
    esac
    echo "link $(display_path "$dst") -> $(display_path "$src"): $state"
    return 0
  fi

  if [ "$state" = "correct" ]; then
    return 0
  fi

  mkdir -p "$(dirname "$dst")"

  if [ "$state" = "link" ]; then
    rm -f "$dst"
  elif [ "$state" = "real" ]; then
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
          if is_dry_run; then
            would_migrate "$name" "old link to remove"
            continue
          fi
          rm -f "$path"
          echo "migrate: removed the old link ~/$name"
          ;;
      esac
    elif [ -e "$path" ]; then
      if [ "$name" = ".gitconfig.override" ] && [ ! -e "$GIT_LOCAL" ]; then
        if is_dry_run; then
          would_migrate "$name" "real file to move to $(display_path "$GIT_LOCAL")"
          continue
        fi
        mkdir -p "$(dirname "$GIT_LOCAL")"
        mv "$path" "$GIT_LOCAL"
        echo "migrate: moved ~/$name to ${GIT_LOCAL/#"$HOME"/\~}"
      else
        if is_dry_run; then
          would_migrate "$name" "real file to back up"
          continue
        fi
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
  local ts entry name ours=1 old_action=""

  if [ -L "$dir" ] || [ ! -d "$dir" ]; then
    return 0
  fi
  ts="$(date +%Y%m%d%H%M%S)"

  # both decisions are made before anything moves, so a dry run reports what a real run does
  if [ -f "$old" ] && [ ! -L "$old" ]; then
    if [ ! -e "$GIT_LOCAL" ]; then
      old_action="move"
    else
      old_action="backup"
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
      local)
        # an identity file that moves out leaves nothing behind, a backed up one stays in the directory
        if [ "$old_action" = "move" ]; then
          continue
        fi
        ;;
    esac
    ours=0
  done < <(find "$dir" -mindepth 1 -maxdepth 1)

  if is_dry_run; then
    case "$old_action" in
      move) would_migrate ".config/git/local" "identity file to move to $(display_path "$GIT_LOCAL")" ;;
      backup) would_migrate ".config/git/local" "identity file to back up, $(display_path "$GIT_LOCAL") already exists" ;;
    esac
    if [ "$ours" = 1 ]; then
      would_migrate ".config/git" "directory of old file links to remove"
      WOULD_REMOVE="$WOULD_REMOVE$dir"$'\n'
    fi
    return 0
  fi

  case "$old_action" in
    move)
      mkdir -p "$(dirname "$GIT_LOCAL")"
      mv "$old" "$GIT_LOCAL"
      echo "migrate: moved ~/.config/git/local to ${GIT_LOCAL/#"$HOME"/\~}"
      ;;
    backup)
      mv "$old" "$old.bak.$ts"
      echo "migrate: ${GIT_LOCAL/#"$HOME"/\~} already exists, backed up ~/.config/git/local to ~/.config/git/local.bak.$ts"
      ;;
  esac

  if [ "$ours" = 1 ]; then
    rm -f "$dir/config" "$dir/ignore" "$dir/message"
    rmdir "$dir"
    echo "migrate: removed the old ~/.config/git directory of file links"
  fi
}

# Whether every fragment in the old ~/.config/mise/conf.d is a plain file that has no namesake in the checkout's config/mise/conf.d.
mise_fragments_movable() {
  local frag

  while IFS= read -r frag; do
    if [ -L "$frag" ] || [ ! -f "$frag" ] || [ -e "$CONFIG_DIR/mise/conf.d/$(basename "$frag")" ]; then
      return 1
    fi
  done < <(find "$HOME/.config/mise/conf.d" -mindepth 1 -maxdepth 1)
}

# ~/.config/mise used to be a real directory holding a link to config.toml, plus the conf.d fragment install-mise.sh writes on the Debian
# family. The fragments move into config/mise/conf.d in the checkout, and the directory is removed when it holds only that, so the
# directory link can take its place. Anything else in it is left for safe_link, which backs the whole directory up.
migrate_mise_dir() {
  local dir="$HOME/.config/mise"
  local dest="$CONFIG_DIR/mise/conf.d"
  local entry name frag ours=1

  if [ -L "$dir" ] || [ ! -d "$dir" ]; then
    return 0
  fi

  while IFS= read -r entry; do
    name="$(basename "$entry")"
    case "$name" in
      config.toml)
        if [ -L "$entry" ] && [ "$(readlink "$entry")" = "$CONFIG_DIR/mise/config.toml" ]; then
          continue
        fi
        ;;
      conf.d)
        if [ -d "$entry" ] && [ ! -L "$entry" ] && mise_fragments_movable; then
          continue
        fi
        ;;
    esac
    ours=0
  done < <(find "$dir" -mindepth 1 -maxdepth 1)

  if is_dry_run; then
    if [ "$ours" = 1 ]; then
      if [ -d "$dir/conf.d" ]; then
        while IFS= read -r frag; do
          would_migrate ".config/mise/conf.d/$(basename "$frag")" "fragment to move to $(display_path "$dest")/"
        done < <(find "$dir/conf.d" -mindepth 1 -maxdepth 1)
      fi
      would_migrate ".config/mise" "directory of old links to remove"
      WOULD_REMOVE="$WOULD_REMOVE$dir"$'\n'
    fi
    return 0
  fi

  if [ "$ours" = 1 ]; then
    if [ -d "$dir/conf.d" ]; then
      mkdir -p "$dest"
      while IFS= read -r frag; do
        mv "$frag" "$dest/"
        echo "migrate: moved ~/.config/mise/conf.d/$(basename "$frag") to ${dest/#"$HOME"/\~}/"
      done < <(find "$dir/conf.d" -mindepth 1 -maxdepth 1)
      rmdir "$dir/conf.d"
    fi
    rm -f "$dir/config.toml"
    rmdir "$dir"
    echo "migrate: removed the old ~/.config/mise directory"
  fi
}

# One safe_link per non-blank line of config/links, skipping the entries for the other OS.
apply_links() {
  local host_os="linux"
  local src dst os

  if [ ! -f "$LINKS_FILE" ]; then
    # a dry run is there to show this, so it goes on to the other steps
    if is_dry_run; then
      echo "warning: $LINKS_FILE not found, a real run stops here (the links are made from the checkout at $DOTS)" >&2
      return 0
    fi
    echo "Missing $LINKS_FILE" >&2
    exit 1
  fi
  if is_dry_run; then
    describe_list "$LINKS_FILE"
  fi
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
migrate_mise_dir
if is_dry_run && [ "$MIGRATIONS" -eq 0 ]; then
  echo "migrate: nothing from the older layout to clear"
fi
apply_links

if [ ! -e "$GIT_LOCAL" ]; then
  echo "No config/git/local found: commits on this machine use the default identity from config/git/config."
  echo "On a new machine, copy config/git/local.example to config/git/local and fill in the email for this machine first."
fi
