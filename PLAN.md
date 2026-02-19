# PLAN

**User Requested Changes**

1. Unify macOS and Linux setups; avoid separate installs per OS while still handling distro differences (Ubuntu, Arch, macOS).
2. Add devbox/Docker-friendly install flow so dotfiles work cleanly in fresh containers for per-client environments and testing.
3. Speed up shell startup by simplifying `zsh/.zshrc` and bootstrap files while keeping behavior.

**Recommended Next Steps**

1. Review `os/macos.sh` defaults to ensure they match current preferences.
2. Validate `config/zsh/.zshrc` plugin list and bootstrap sourcing for macOS vs Linux.
3. Refresh README to fully reflect the new layout and install steps.

**Known Fixes To Apply**

1. Fix `nmp/globals` typo in `scripts/install.sh` or add npm globals installer using pnpm.

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

1. Create OS-specific package lists under `packages/`. (done)
2. Add `scripts/install-packages.sh` to install from `apt.txt` or `pacman.txt`. (done)
3. Move `brew/brewfile` to `packages/Brewfile` and update install scripts. (done)

**Refactor Steps**

1. Create new `config/`, `scripts/`, and `os/` layout alongside existing files. (done)
2. Move configs from `zsh/`, `git/`, `tmux/`, `vim/`, `vscode/`, `asdf/`, `nvm/`, `atuin/` into `config/`. (done)
3. Split existing install logic into: (done)
   - `scripts/install.sh` (orchestration + OS detection)
   - `scripts/install-packages.sh` (already exists)
   - `scripts/install-dotfiles.sh` (symlinks only)
   - `scripts/install-shell.sh` (Oh My Zsh, plugins, p10k)
4. Move `macos.sh` into `os/macos.sh` and add `os/ubuntu.sh`, `os/arch.sh` as needed. (done)
5. Update container Dockerfiles and entrypoints to use `scripts/install.sh` or `install-container.sh`. (done)
6. Update README with new layout and install instructions. (done)
7. Remove deprecated files/paths once parity is confirmed. (done)

**Next Refactors**:

- abstract os_id handling to utils folder, and reuse across scripts
- move /npm folder to config, and add handler to install npm global packages, it should use pnpm for the installs, also as a rule, update agents to always use pnpm rather than npm
- extensions, how to make them better? I dont like to have to create separate repositories for each private or separate config that I want
