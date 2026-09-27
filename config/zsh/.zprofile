# Kept empty on purpose, comments only. zsh reads $ZDOTDIR/.zprofile once per login shell, and some tools (OrbStack did) append their shell init to it.
# Tracked so that an append shows up as a modified file in `git status`, not as an untracked surprise.
# Shell setup lives elsewhere: environment in .zshenv, interactive setup in .zshrc, and tool hooks in config/<tool>/init.zsh (sourced by .bootstrap).
# If a tool appends lines here, move what it needs into a hook and revert the edit.
