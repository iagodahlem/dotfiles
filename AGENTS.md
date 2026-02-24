# AGENTS

Repository context for Codex and other agents.

**Overview**
This is a personal dotfiles repo for macOS and Linux setup. It contains static config under `config/`, installer scripts under `scripts/`, OS tweaks under `os/`, and optional overrides via `overlays/`.

**Key Paths**

- `scripts/install.sh` is the public entrypoint (orchestration + OS detection).
- `scripts/install-packages.sh` installs dependencies from `packages/`.
- `scripts/install-dotfiles.sh` manages symlinks in `$HOME`.
- `scripts/install-shell.sh` installs Oh My Zsh + plugins/themes.
- `scripts/install-node-globals.sh` installs global Node packages from `config/npm/globals` using `pnpm`.
- `scripts/install-container.sh` runs a container-safe subset.
- `scripts/utils/os.sh` provides shared `os_id()` detection.
- `os/macos.sh` applies macOS defaults; `os/ubuntu.sh` and `os/arch.sh` are placeholders.
- `containers/` contains Ubuntu/Arch devbox Dockerfiles and entrypoint.
- `overlays/` holds OS- and host-specific shell overrides (see `overlays/README.md`).

**How Config Loads**

- `config/zsh/.zshrc` sets base env, loads Oh My Zsh, then sources `config/zsh/.bootstrap`.
- `config/zsh/.bootstrap` loads base shell files (`.exports`, `.aliases`, `.functions`), then optional overlays from `overlays/os/<os>/` and `overlays/host/<name>/`, then per-tool init (`asdf`, `atuin`, `brew`, `cargo`, `nvm`).
- `config/zsh/.p10k.zsh` is loaded by `.zshrc` when present in `$HOME`.

**Assumptions**

- Primary target is macOS, with Linux (Ubuntu/Arch) support.
- This repo can be in a dirty state; do not assume a clean git worktree.
- Install scripts are destructive/system-changing (packages, symlinks, OS defaults).

**Known Gaps (current state)**

- `os/ubuntu.sh` and `os/arch.sh` are placeholders.
- Container "customer box" templates (`containers/examples/` or `.devcontainer/`) are not implemented yet.
- Shell startup still initializes both `asdf` and `nvm`; more startup tuning is possible.

**Roadmap (user intent)**

- Keep one unified install flow with OS/distro-specific branches.
- Keep dotfiles runnable inside Docker devboxes for client/testing contexts.
- Continue reducing shell startup overhead while preserving behavior.

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
