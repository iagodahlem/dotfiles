# PLAN

Status snapshot updated on 2026-09-24.

## Goals

1. Keep a single install flow for macOS, Arch, and Debian (Raspberry Pi OS) with OS-specific branches.
2. Keep dotfiles runnable in Docker devboxes for client environments, testing, and isolated development.
3. Improve shell startup time without regressing behavior.

## Current State

### Completed

1. Unified repo layout under `config/`, `scripts/`, `os/`, `packages/`, `containers/`, and `overlays/`.
2. Shared package installer (`scripts/install-packages.sh`) for apt/pacman/brew.
3. Unified orchestration entrypoint (`scripts/install.sh`) with skip flags.
4. Container images for Ubuntu and Arch with smoke script coverage.
5. Single compose file with multiple services (`devbox`, `devbox-arch`, `devbox-isolated`).
6. CI runs shellcheck in a dedicated container and smoke tests for both Dockerfiles.
7. Global Node package installer via `pnpm` (`scripts/install-node-globals.sh`).
8. Overlay model replacing extension repositories.
9. Per-machine git identity override (`~/.gitconfig.override`) and the new-machine setup doc (`docs/new-mac.md`).

## Phases

1. Docs and triage (done): README, AGENTS, TOOLS, PLAN, and TASKS match the tree, plus the per-machine identity and the alias cleanup.
2. Packages: Brewfile core plus host overlay Brewfiles applied by `brew bundle`, categorized package lists with a Debian path, `install-ai-clis.sh`, and node and pnpm from mise instead of nvm.
3. XDG layout: `~/.zshenv` sets the XDG variables and `ZDOTDIR`, directory links into `~/.config`, a declarative link table, and migration of the old `~` links.
4. Installer: `--help` and `--dry-run`, a `NONINTERACTIVE` Homebrew bootstrap, `pacman -Syu --needed`, pinned shell plugins, and `os/macos.sh` trimmed to the settings that still apply.
5. Host overlays and host-level split: one overlay per machine selected by `DOTFILES_HOST` from `hostname -s`, and host-level settings (firewall, timezone, services, drivers) moving out to the host configuration repo.

Items that are not tied to a phase (LazyVim config, clipboard fixes, overlay lint, startup timing) stay in `TASKS.md`.
