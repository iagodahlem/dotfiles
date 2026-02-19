# AGENTS

Repository context for Codex and other agents.

**Overview**
This is a personal dotfiles repo focused on macOS setup. It contains shell config, editor settings, and install scripts that symlink files into `$HOME` and apply macOS defaults. There are optional extensions under `extensions/` for Linux and work-specific setups.

**Key Paths**
- `scripts/install.sh` is the main entrypoint (OS detection + orchestrates installs).
- `scripts/install-dotfiles.sh` manages symlinks; `scripts/install-shell.sh` installs Oh My Zsh + plugins.
- `install-dotfiles.sh` is a compatibility wrapper that calls `scripts/install.sh`.
- `install-apps.sh` installs GUI apps and fonts via Homebrew Cask.
- `os/macos.sh` applies macOS defaults and SSD tweaks (`macos.sh` is a wrapper).
- `config/` contains tool configs (`zsh/`, `git/`, `tmux/`, `vim/`, `vscode/`, `asdf/`, `nvm/`, `atuin/`).
- `packages/` contains package lists for different OSes (`Brewfile`, `apt.txt`, `pacman.txt`, `aur.txt`).
- `containers/` contains devbox Dockerfiles and entrypoint.
- `scripts/` contains installers and CI smoke tests.
- `extensions/` contains optional extension repos (Linux and Sticker Mule).

**How Config Loads**
- `config/zsh/.zshrc` sources `config/zsh/.bootstrap`, which then loads `.exports`, `.aliases`, `.functions` and optional extension bootstraps.
- `config/zsh/.bootstrap` sources per-tool init files: `brew/.homebrew`, `config/asdf/.asdf`, `config/nvm/.nvm`, `config/atuin/.atuin`.
  - `config/zsh/.p10k.zsh` is present and loaded by `.zshrc` if it exists in `$HOME`.

**Assumptions**
- Primary OS target is macOS, but `zsh` and extension folders support Linux variants.
- This repo can be in a dirty state; do not assume a clean git worktree.
- Do not run install scripts automatically without confirmation because they are destructive (system changes and package installs).

**Known Gaps (current state)**
- `install-apps.sh` references `brew/caskfile` and `brew/fontfile`, which are not present.
- `install-dotfiles.sh` references `nmp/globals` (typo) but the file is `npm/globals`.
- `packages/Brewfile` mixes CLI and GUI apps; the install script uses `brew install` directly.
 - The container flow is Ubuntu-based; distro variants (Arch/Alpine) are not yet standardized.

**Roadmap (user intent)**
- Unify macOS and Linux setup into a single flow with OS/distro-specific branches.
- Make dotfiles runnable inside Docker-based devboxes for client-specific environments and testing.
- Speed up shell startup by simplifying `zsh/.zshrc` and bootstrap files.

**Editing Guidelines**
- Prefer minimal changes and keep scripts portable.
- If changing install flows, update both scripts and README in the same change.
- Keep new files ASCII-only unless the file already contains Unicode.
