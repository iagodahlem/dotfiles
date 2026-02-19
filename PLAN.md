# PLAN

**User Requested Changes**
1. Unify macOS and Linux setups; avoid separate installs per OS while still handling distro differences (Ubuntu, Arch, macOS).
2. Add devbox/Docker-friendly install flow so dotfiles work cleanly in fresh containers for per-client environments and testing.
3. Speed up shell startup by simplifying `zsh/.zshrc` and bootstrap files while keeping behavior.

**Recommended Next Steps**
1. Decide on a single Homebrew flow (`brew bundle` with a `Brewfile`, or separate `brew install` and `brew install --cask`) and align `install-dotfiles.sh`, `install-apps.sh`, and `brew/brewfile`.
2. Fix missing and mismatched paths in scripts.
3. Review `macos.sh` defaults to ensure they match current preferences.
4. Validate `zsh/.zshrc` plugin list and bootstrap sourcing for macOS vs Linux.
5. Refresh README to match the actual install steps and file names.

**Known Fixes To Apply**
1. Add `brew/caskfile` and `brew/fontfile`, or remove references and use a unified `brew/brewfile`.
2. Fix `nmp/globals` typo in `install-dotfiles.sh` to `npm/globals`.

**Plan: Devbox/Docker Flow (Priority)**
1. Define container strategy and entry points.
   - Create `containers/` with:
     - `Dockerfile` for a base devbox image. (done)
     - `entrypoint.sh` to enter the target user. (done)
2. Add a container-safe install mode.
   - Add a script (e.g. `scripts/install-container.sh`) that:
     - Skips macOS-specific steps and `sudo` defaults.
     - Runs a minimal dotfiles install (zsh, git, tmux, vim, configs, shell init).
     - Accepts `DOTFILES_INSTALL_MODE=container` and `DOTFILES_CONTAINER_MINIMAL=0|1`. (done)
   - Add a smoke test script for local and CI validation. (done: `scripts/devbox-smoke.sh`)
3. Make dotfiles cloneable inside containers.
   - Use `ARG DOTFILES_REPO` and `ARG DOTFILES_BRANCH` in Dockerfile.
   - Clone into `/home/dev/.dotfiles` and run container install script.
4. Add a "customer box" pattern.
   - Provide a `containers/examples/` or `.devcontainer/` template that mounts a per-client workspace.
   - Document how to add project-specific packages via compose overrides.
5. Add fast validation targets.
   - GitHub Actions workflow runs the smoke test on push. (done)
6. Document the workflow in README.
   - How to build, run, and customize images.
   - How to add per-client dependencies.
   - How to test dotfiles inside a container.

**Packages (Shared)**
1. Create OS-specific package lists under `packages/`.
2. Add `scripts/install-packages.sh` to install from `apt.txt` or `pacman.txt`.
3. Move `brew/brewfile` to `packages/Brewfile` and update install scripts.

**Target Architecture**
```
.
├── packages/                # Source of truth for deps
│   ├── Brewfile
│   ├── apt.txt
│   ├── pacman.txt
│   └── aur.txt
├── scripts/                 # All logic lives here
│   ├── install.sh           # entrypoint: detects OS + runs tasks
│   ├── install-packages.sh  # installs packages from packages/
│   ├── install-dotfiles.sh  # symlinks configs
│   ├── install-shell.sh     # oh-my-zsh, plugins, p10k
│   └── install-container.sh # container-safe subset
├── os/                      # OS-specific tweaks
│   ├── macos.sh
│   ├── ubuntu.sh
│   └── arch.sh
├── config/                  # App configs
│   ├── zsh/
│   ├── git/
│   ├── tmux/
│   ├── vim/
│   └── vscode/
├── containers/
│   ├── Dockerfile.ubuntu
│   ├── Dockerfile.arch
│   ├── entrypoint.sh
│   └── docker-compose.arch.yml
├── docker-compose.yml
├── README.md
└── AGENTS.md
```

**Principles (to document in README later)**
1. `packages/` is the single source of truth for dependencies.
2. `scripts/install.sh` is the only public entrypoint; everything else is a sub-step.
3. `os/` holds OS-only tweaks and defaults.
4. `config/` is purely static configs; scripts should never “know” their contents.
5. Containers use the same `scripts/` entrypoint (no duplicated logic).

**Refactor Steps**
1. Create new `config/`, `scripts/`, and `os/` layout alongside existing files.
2. Move configs from `zsh/`, `git/`, `tmux/`, `vim/`, `vscode/`, `asdf/`, `nvm/`, `atuin/` into `config/`.
3. Split existing install logic into:
   - `scripts/install.sh` (orchestration + OS detection)
   - `scripts/install-packages.sh` (already exists)
   - `scripts/install-dotfiles.sh` (symlinks only)
   - `scripts/install-shell.sh` (Oh My Zsh, plugins, p10k)
4. Move `macos.sh` into `os/macos.sh` and add `os/ubuntu.sh`, `os/arch.sh` as needed.
5. Update container Dockerfiles and entrypoints to use `scripts/install.sh` or `install-container.sh`.
6. Update README with new layout and install instructions.
7. Remove deprecated files/paths once parity is confirmed.
