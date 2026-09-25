# AGENTS

Repository context for Codex and other agents.

**Overview**
This is a personal dotfiles repo for macOS, Arch, and Debian (Raspberry Pi OS) setup. It contains static config under `config/`, installer scripts under `scripts/`, OS tweaks under `os/`, and optional overrides via `overlays/`.

**Key Paths**

- `scripts/install.sh` is the public entrypoint (orchestration + OS detection).
- `scripts/install-packages.sh` installs dependencies from `packages/`.
- `scripts/install-dotfiles.sh` manages symlinks in `$HOME` (including `config/mise/.tool-versions` to `~/.tool-versions`).
- `scripts/install-shell.sh` installs Oh My Zsh + plugins/themes.
- `scripts/install-node-globals.sh` installs global Node packages from `config/npm/globals` using `pnpm`.
- `scripts/devbox-smoke.sh` builds and validates container images.
- `scripts/lint-shell.sh` runs shellcheck over shell scripts.
- `scripts/utils/os.sh` provides shared `os_id()` detection.
- `os/macos.sh` applies macOS defaults (`defaults`, `nvram`, `pmset`).
- `os/ubuntu.sh` (also used for Debian) sets locale and timezone, switches the login shell to zsh, adds the user to the docker group, and enables the docker and tailscale services.
- `os/arch.sh` does the same as `os/ubuntu.sh`, plus the paccache timer, ufw defaults, and the liquidctl service.
- `containers/` contains Ubuntu/Arch devbox Dockerfiles plus shared entrypoint.
- `docker-compose.yml` defines all devbox services (`devbox`, `devbox-arch`, `devbox-isolated`).
- `overlays/` holds OS- and host-specific shell overrides (see `overlays/README.md`).
- `docs/new-mac.md` is the setup sequence for a new machine, including the per-machine git identity.
- `TOOLS.md` lists everything installed and aliased, `TASKS.md` tracks open work, and `PLAN.md` lays out the next phases.

**How Config Loads**

- `config/zsh/.zshrc` sets base env, loads Oh My Zsh, then sources `config/zsh/.bootstrap`.
- `config/zsh/.bootstrap` loads base shell files (`.exports`, `.aliases`, `.functions`), then optional overlays from `overlays/os/<id>/` and `overlays/host/<name>/`, then per-tool init (`mise`, `atuin`, `brew`, `cargo`, `nvm`).
- `config/git/.gitconfig` ends with `[include] path = ~/.gitconfig.override`, an untracked per-machine file. See `config/git/.gitconfig.override.example` and `docs/new-mac.md`.
- `config/zsh/.p10k.zsh` is loaded by `.zshrc` when present in `$HOME`.

**Assumptions**

- Targets: macOS, Arch, Debian (Raspberry Pi OS). Ubuntu stays covered through the apt path and the Ubuntu container.
- This repo can be in a dirty state; do not assume a clean git worktree.
- Install scripts are destructive/system-changing (packages, symlinks, OS defaults).
- Containers are used both for test validation and optional isolated dev environments.

**Known Gaps (current state)**

- `.devcontainer/` templates are not implemented yet (parked in `TASKS.md`).
- Shell startup still initializes both `mise` and `nvm`, and node still comes from `nvm`; dropping `nvm` is the first open item in `TASKS.md`, and more startup tuning follows it.

**Roadmap (user intent)**

- Keep one unified install flow with OS/distro-specific branches.
- Keep dotfiles runnable inside Docker devboxes for client/testing contexts.
- Continue reducing shell startup overhead while preserving behavior.
- Follow the phases in `PLAN.md`: packages, XDG layout, installer, then host overlays and the host-level split.

**Editing Guidelines**

- Prefer minimal, portable changes.
- If changing install flows, update scripts and docs (`README.md`, `AGENTS.md`) in the same change.
- Keep new files ASCII-only unless the file already contains Unicode.
- Prefer `pnpm` over `npm` for global package installs.

**Principles**

1. `packages/` is the single source of truth for dependencies.
2. `scripts/install.sh` is the only public entrypoint; everything else is a sub-step.
3. `os/` holds OS-only tweaks and defaults.
4. `config/` is static config; scripts should not hardcode private config content.
5. Containers should reuse the same scripts flow (no duplicated install logic).
