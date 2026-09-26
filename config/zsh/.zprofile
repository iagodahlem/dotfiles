# Read by login shells only, from ZDOTDIR (the checkout), after .zshenv and before .zshrc.
# It holds OrbStack's shell init: OrbStack appends the block below to the login profile on its first launch, which with ZDOTDIR in the checkout is this file, so it is tracked instead of showing up as an untracked file.
# OrbStack edits the profile once and its own comment says it does not add the block again after it is removed; the docs do not say whether it looks for the marker lines, so they stay as OrbStack wrote them.
# The source line is guarded (2>/dev/null || :), so a machine without OrbStack starts a login shell without an error.

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
