# PLAN

Status snapshot updated on 2026-02-24.

## Goals

1. Keep a single install flow for macOS and Linux (Ubuntu/Arch) with OS-specific branches.
2. Keep dotfiles runnable in Docker devboxes for client environments and testing.
3. Improve shell startup time without regressing behavior.

## Current State

### Completed

1. Unified repo layout under `config/`, `scripts/`, `os/`, `packages/`, `containers/`, and `overlays/`.
2. Shared package installer (`scripts/install-packages.sh`) for apt/pacman/brew.
3. Unified orchestration entrypoint (`scripts/install.sh`) with skip flags.
4. Container install path (`scripts/install-container.sh`) and smoke test (`scripts/devbox-smoke.sh`).
5. Global Node package installer via `pnpm` (`scripts/install-node-globals.sh`).
6. Overlay model replacing extension repositories.

### Open

1. Implement distro-specific defaults in `os/ubuntu.sh` and `os/arch.sh`.
2. Decide and implement "customer box" templates (`containers/examples/` or `.devcontainer/`).
3. Decide whether Dockerfiles should support `DOTFILES_REPO`/`DOTFILES_BRANCH` clone mode in addition to local `COPY .`.
4. Continue shell startup cleanup (`.zshrc`/`.bootstrap`) and measure impact.

## Next Actions

1. Add baseline Ubuntu/Arch defaults (safe, reversible settings only).
2. Choose one container customization pattern and document it in README.
3. Add startup timing checks (e.g. repeatable `zsh -i -c exit` benchmark) before/after shell changes.
4. Keep README/AGENTS in lockstep with any install-flow edits.
