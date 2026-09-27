# OrbStack's shell init: its bin directory on PATH and its shell completions, only where the app has created it (macOS)
# the file exists once OrbStack has run, so a machine without OrbStack, or one that has not launched it yet, gets nothing
[ -r "$HOME/.orbstack/shell/init.zsh" ] && source "$HOME/.orbstack/shell/init.zsh"
