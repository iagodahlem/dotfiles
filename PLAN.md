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
   - Create `containers/` (or `.devcontainer/`) with:
     - `Dockerfile` for a base devbox image.
     - `docker-compose.yml` to layer per-project dependencies.
     - Optional `devcontainer.json` for VS Code/Dev Containers support.
2. Add a container-safe install mode.
   - Add a script (e.g. `scripts/install-container.sh`) that:
     - Skips macOS-specific steps and `sudo` defaults.
     - Runs a minimal dotfiles install (zsh, git, tmux, vim, configs, shell init).
     - Accepts `DOTFILES_INSTALL_MODE=container` and `DOTFILES_PACKAGES=base|full`.
3. Make dotfiles cloneable inside containers.
   - Use `ARG DOTFILES_REPO` and `ARG DOTFILES_BRANCH` in Dockerfile.
   - Clone into `/home/dev/.dotfiles` and run container install script.
4. Add a "customer box" pattern.
   - Provide a `containers/examples/` or `.devcontainer/` template that mounts a per-client workspace.
   - Document how to add project-specific packages via compose overrides.
5. Add fast validation targets.
   - `make devbox-build` to build the image.
   - `make devbox-run` to open a shell in the image.
   - `make devbox-test` to run a smoke check that confirms symlinks and shell boot.
6. Document the workflow in README.
   - How to build, run, and customize images.
   - How to add per-client dependencies.
   - How to test dotfiles inside a container.
