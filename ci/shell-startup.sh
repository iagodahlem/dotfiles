#!/usr/bin/env bash
# Times an interactive zsh startup: runs `zsh -i -c exit` N times and prints the min, median and max in milliseconds. With --profile it runs one interactive shell under zsh/zprof instead and prints the 15 costliest entries.
# $HOME decides what is measured, so it works against the real home and against a scratch one laid out like a machine that cloned the checkout to ~/.dotfiles:
#   HOME=<dir> ci/shell-startup.sh
# It prints numbers and gates nothing, since they depend on the machine.
set -euo pipefail

RUNS=10
PROFILE=0

usage() {
  cat <<'EOF'
Usage: ci/shell-startup.sh [-n RUNS] [--profile]

  -n RUNS     time RUNS interactive shells (default 10) and print the min, median and max in milliseconds
  --profile   run one interactive shell under zsh/zprof and print the 15 costliest entries instead
  -h, --help  show this help

The shell starts from $HOME (~/.zshenv, then the ZDOTDIR it sets), so HOME=<dir> measures a scratch home.
EOF
}

fail() {
  echo "shell-startup: $*" >&2
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -n)
      [ "$#" -ge 2 ] || fail "-n needs a number of runs"
      RUNS="$2"
      shift 2
      ;;
    --profile)
      PROFILE=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "unknown argument: $1"
      ;;
  esac
done

case "$RUNS" in
  '' | *[!0-9]* | 0) fail "-n takes a positive number, got '$RUNS'" ;;
esac

command -v zsh >/dev/null 2>&1 || fail "zsh is not installed"
zsh_bin="$(command -v zsh)"

# .zshenv keeps the XDG variables, ZDOTDIR and DOTFILES already exported, so a shell started from a terminal that has them set would read the real home whatever HOME says
# a fresh login gets them from ~/.zshenv, so drop them and let the shell work them out from $HOME
shell_env=(env -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u XDG_STATE_HOME -u XDG_CACHE_HOME -u ZDOTDIR -u DOTFILES -u DOTFILES_PRIVATE)

# a home that lacks the links or oh-my-zsh still starts a shell, only a much faster one than the setup this measures, so refuse it
[ -r "$HOME/.zshenv" ] || fail "$HOME/.zshenv is missing: link the checkout (scripts/install-dotfiles.sh) or point HOME at a home that has it"
# shellcheck disable=SC2016 # the variables are the child shell's
paths="$("${shell_env[@]}" "$zsh_bin" -c 'print -rl -- $ZDOTDIR $ZSH' </dev/null)"
{ IFS= read -r zdotdir && IFS= read -r omz_dir; } <<<"$paths" || fail "$HOME/.zshenv does not set ZDOTDIR and ZSH"
[ -r "$zdotdir/.zshrc" ] || fail "no .zshrc in ZDOTDIR ($zdotdir): $HOME/.zshenv does not lead to the config"
[ -r "$omz_dir/oh-my-zsh.sh" ] || fail "oh-my-zsh is missing at $omz_dir: run scripts/install-shell.sh"

# mise walks up from the directory a shell starts in to find tool versions, so start in $HOME as a new terminal does: a checkout under another home would pick up that home's .tool-versions
cd "$HOME"

# The first shells in a home build the completion dump and compile it, which is not what a shell costs afterwards, so two run before anything is measured
# their output is dropped everywhere: without a terminal Powerlevel10k prints errors once its instant prompt cache exists, and the timing is the same
"${shell_env[@]}" "$zsh_bin" -i -c exit </dev/null >/dev/null 2>&1 || true
"${shell_env[@]}" "$zsh_bin" -i -c exit </dev/null >/dev/null 2>&1 || true

if [ "$PROFILE" = 1 ]; then
  # zprof only sees what runs after it is loaded, and .zshrc is too late. zsh reads $ZDOTDIR/.zshenv in place of ~/.zshenv when ZDOTDIR is already set,
  # so a directory of its own holds a .zshenv that loads zprof and then reads the real ~/.zshenv, which sets ZDOTDIR for the rest of the startup
  # zprof lists functions, so what a block spends in a command it forks (mise, atuin, brew) is charged to the code that ran it and never has an entry
  profile_dir="$(mktemp -d)"
  trap 'rm -rf "$profile_dir"' EXIT
  # shellcheck disable=SC2016 # zsh code, expanded by the shell that reads the file
  printf '%s\n' 'zmodload zsh/zprof' 'source "$HOME/.zshenv"' > "$profile_dir/.zshenv"
  echo "zprof, one interactive shell, HOME=$HOME"
  "${shell_env[@]}" ZDOTDIR="$profile_dir" "$zsh_bin" -i -c zprof </dev/null 2>/dev/null |
    awk 'NR <= 2 { print; next } /^ *[0-9]+\)/ && n++ < 15 { print }'
  exit 0
fi

# The timing runs inside zsh: EPOCHREALTIME comes with it, unlike date +%N which macOS does not have, and zsh -f (no startup files) keeps this wrapper out of the numbers
# shellcheck disable=SC2016 # zsh code, expanded by the shell that runs it
timer='zmodload zsh/datetime
repeat $1 {
  start=$EPOCHREALTIME
  $2 -i -c exit </dev/null >/dev/null 2>&1
  printf "%.1f\n" $(( (EPOCHREALTIME - start) * 1000 ))
}'
times="$("${shell_env[@]}" "$zsh_bin" -f -c "$timer" zsh "$RUNS" "$zsh_bin")"

echo "zsh -i -c exit, $RUNS runs, HOME=$HOME"
printf '%s\n' "$times" | sort -n | awk '
  { v[NR] = $1 }
  END {
    mid = int((NR + 1) / 2)
    median = (NR % 2) ? v[mid] : (v[mid] + v[mid + 1]) / 2
    printf "  min     %6.1f ms\n  median  %6.1f ms\n  max     %6.1f ms\n", v[1], median, v[NR]
  }'
