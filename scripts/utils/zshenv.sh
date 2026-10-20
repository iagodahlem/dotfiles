#!/usr/bin/env bash

# Marks a variable zsh itself leaves unset after sourcing ~/.zshenv, so a caller can tell "unset" from "set to the empty string".
ZSHENV_UNSET_MARK="__dotfiles_zshenv_unset__"

# Prints "VAR=value" for each variable name passed, one per line in that order, resolved the way a zsh login shell would see
# it: by sourcing $HOME/.zshenv under zsh itself, local.zshenv included (config/zsh/local.zshenv, which .zshenv only sources
# under zsh, see "How Config Loads" in AGENTS.md). A var local.zshenv unsets, CLAUDE_CONFIG_DIR on a work machine that keeps
# the stock ~/.claude for the company's Claude Code say, prints as ZSHENV_UNSET_MARK instead of its XDG default.
# Needs zsh; the caller decides what to do when it is missing (scripts/gui-env-launchagent.sh and install-dotfiles.sh's
# warn_codex_split_state both fall back to sourcing ~/.zshenv from bash instead, which never reaches local.zshenv either).
resolve_zshenv_vars() {
  local var script=""

  for var in "$@"; do
    script="${script}print -r -- \"$var=\${${var}-$ZSHENV_UNSET_MARK}\"; "
  done
  zsh -c ". \"\$HOME/.zshenv\"; $script"
}
