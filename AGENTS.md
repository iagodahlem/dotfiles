# AGENTS

Repository context for Codex and other agents.

**Overview**
This is a personal dotfiles repo focused on macOS setup. It contains shell config, editor settings, and install scripts that symlink files into `$HOME` and apply macOS defaults. There are optional extensions under `extensions/` for Linux and work-specific setups.

**Key Paths**
- `install-dotfiles.sh` installs Homebrew packages, symlinks dotfiles, installs Oh My Zsh plugins, sets up VS Code, asdf, nvm, tmux, and applies `macos.sh` defaults.
- `install-apps.sh` installs GUI apps and fonts via Homebrew Cask.
- `macos.sh` applies macOS defaults and SSD tweaks.
- `zsh/` contains `.zshrc`, `.aliases`, `.functions`, `.exports` and bootstrap wiring.
- `containers/` contains a minimal devbox Docker image and entrypoint.
- `scripts/` contains container install and smoke test scripts.
- `git/`, `tmux/`, `vim/`, `vscode/`, `asdf/`, `nvm/`, `atuin/` hold tool configs and helper scripts.
- `extensions/` contains optional extension repos (Linux and Sticker Mule).

**How Config Loads**
- `zsh/.zshrc` sources `zsh/.bootstrap`, which then loads `.exports`, `.aliases`, `.functions` and optional extension bootstraps.
- `zsh/.bootstrap` sources per-tool init files: `brew/.homebrew`, `asdf/.asdf`, `nvm/.nvm`, `atuin/.atuin`.
  - `zsh/.p10k.zsh` is present and loaded by `.zshrc` if it exists in `$HOME`.

**Assumptions**
- Primary OS target is macOS, but `zsh` and extension folders support Linux variants.
- This repo can be in a dirty state; do not assume a clean git worktree.
- Do not run install scripts automatically without confirmation because they are destructive (system changes and package installs).

**Known Gaps (current state)**
- `install-apps.sh` references `brew/caskfile` and `brew/fontfile`, which are not present.
- `install-dotfiles.sh` references `nmp/globals` (typo) but the file is `npm/globals`.
- `brew/brewfile` mixes CLI and GUI apps; the install script uses `brew install` directly.
 - The container flow is Ubuntu-based; distro variants (Arch/Alpine) are not yet standardized.

**Roadmap (user intent)**
- Unify macOS and Linux setup into a single flow with OS/distro-specific branches.
- Make dotfiles runnable inside Docker-based devboxes for client-specific environments and testing.
- Speed up shell startup by simplifying `zsh/.zshrc` and bootstrap files.

**Editing Guidelines**
- Prefer minimal changes and keep scripts portable.
- If changing install flows, update both scripts and README in the same change.
- Keep new files ASCII-only unless the file already contains Unicode.
