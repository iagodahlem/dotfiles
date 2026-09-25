# AGENTS

Repository context for Codex and other agents.

**Overview**
This is a personal dotfiles repo for macOS, Arch, and Debian (Raspberry Pi OS) setup. It contains static config under `config/`, installer scripts under `scripts/`, OS tweaks under `os/`, and optional overrides via `overlays/`.

**Key Paths**

- `scripts/install.sh` is the public entrypoint (orchestration + OS detection).
- `scripts/install-packages.sh` installs dependencies from `packages/`: `brew bundle` on `packages/Brewfile` plus the host Brewfile (`overlays/host/<DOTFILES_HOST or hostname -s>/Brewfile`) on macOS, `apt.txt` on the Debian family, `pacman.txt` and `aur.txt` on Arch.
- `scripts/install-apt-repos.sh` adds the Docker, Tailscale, eza and Azlux apt sources before `install_apt` runs `apt-get update`; it is idempotent and never prompts.
- `scripts/install-dotfiles.sh` manages symlinks in `$HOME` (including `config/mise/config.toml` to `~/.config/mise/config.toml` and `config/mise/.tool-versions` to `~/.tool-versions`).
- `scripts/install-shell.sh` installs Oh My Zsh + plugins/themes.
- `scripts/install-mise.sh` installs mise where no package list does (Debian family, `https://mise.run`), then node and pnpm from `config/mise/config.toml`, atuin and procs on the Debian family, and runs `corepack enable`.
- `scripts/install-ai-clis.sh` installs claude, codex and gemini from their own installers (`--update` refreshes installed ones).
- `scripts/devbox-smoke.sh` builds and validates container images.
- `scripts/lint-shell.sh` runs shellcheck over shell scripts.
- `scripts/utils/os.sh` provides shared `os_id()` detection; `scripts/utils/paths.sh` puts Homebrew and `~/.local/bin` on `PATH` for installer steps.
- `os/macos.sh` applies macOS defaults (`defaults`, `nvram`, `pmset`).
- `os/ubuntu.sh` (also used for Debian and Raspberry Pi OS) sets locale and timezone, switches the login shell to zsh, adds the user to the docker group, and enables the docker and tailscale services.
- `os/arch.sh` does the same as `os/ubuntu.sh`, plus the paccache timer, ufw defaults, and the liquidctl service.
- `containers/` contains Ubuntu/Arch devbox Dockerfiles plus shared entrypoint.
- `docker-compose.yml` defines all devbox services (`devbox`, `devbox-arch`, `devbox-isolated`).
- `overlays/` holds OS- and host-specific shell overrides and the per-host Brewfiles (see `overlays/README.md`).
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
- Node and pnpm now come from `mise`, but shell startup still sources `nvm` after it; on a machine that has `nvm` installed its node wins until the hook is dropped. That is the first open item in `TASKS.md`, and more startup tuning follows it.

**Roadmap (user intent)**

- Keep one unified install flow with OS/distro-specific branches.
- Keep dotfiles runnable inside Docker devboxes for client/testing contexts.
- Continue reducing shell startup overhead while preserving behavior.
- Follow the phases in `PLAN.md`: XDG layout, installer, then host overlays and the host-level split (the packages phase is done).

**Editing Guidelines**

- Prefer minimal, portable changes.
- If changing install flows, update scripts and docs (`README.md`, `AGENTS.md`) in the same change.
- Keep new files ASCII-only unless the file already contains Unicode.
- Prefer `pnpm` over `npm` for global package installs, except where a vendor documents an npm command (gemini in `install-ai-clis.sh`).
- Package lists take trailing `# comments` (`read_list_items` strips them), so keep a short comment on any entry whose name does not explain itself. Debian names go in `apt.txt`; a package that only exists in a third-party repo needs its source in `install-apt-repos.sh`.

**Principles**

1. `packages/` is the single source of truth for dependencies.
2. `scripts/install.sh` is the only public entrypoint; everything else is a sub-step.
3. `os/` holds OS-only tweaks and defaults.
4. `config/` is static config; scripts should not hardcode private config content.
5. Containers should reuse the same scripts flow (no duplicated install logic).
