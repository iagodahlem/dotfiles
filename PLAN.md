# PLAN

Status snapshot updated on 2026-02-24.

## Goals

1. Keep a single install flow for macOS and Linux (Ubuntu/Arch) with OS-specific branches.
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

### Open

1. Implement distro-specific defaults in `os/ubuntu.sh` and `os/arch.sh`.
2. Add optional `.devcontainer/` templates that reuse existing Dockerfiles/services.
3. Continue shell startup cleanup (`.zshrc`/`.bootstrap`) and measure impact.

## Next Actions

1. Add baseline Ubuntu/Arch defaults (safe, reversible settings only).
2. Add a `.devcontainer/devcontainer.json` variant for bind-mounted workspace and one isolated variant.
3. Add repeatable startup timing checks (`zsh -i -c exit`) before/after shell changes.
4. Keep README/AGENTS in lockstep with install/container flow edits.
