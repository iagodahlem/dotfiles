# PLAN

Status snapshot updated on 2026-09-25.

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
6. CI runs shellcheck in a dedicated container, the installer dry run on the runner, and smoke tests for both Dockerfiles.
7. Overlay model replacing extension repositories.
8. Per-machine git identity override (`config/git/local`) and the new-machine setup doc (`docs/new-mac.md`).
9. Package layer reset: core Brewfile plus host overlay Brewfiles applied by `brew bundle`, categorized Arch and Debian lists, the Debian install path with its third-party apt repositories, node and pnpm from mise, and the AI CLIs from their own installers.
10. XDG layout: one `~/.zshenv` that sets the XDG variables and `ZDOTDIR`, directory links into `~/.config` from the table in `config/links`, migration of the old `~` links, oh-my-zsh, Powerlevel10k, the zsh plugins and tpm cloned under the XDG data directory, the tracked LazyVim config with a headless plugin sync, and nvm dropped for mise.
11. Installer: `install.sh --help`, `--only <step>` and `--dry-run` (every step prints what it would do and changes nothing, with `ci/dry-run.sh` as a CI job), `os/macos.sh` trimmed to the settings that still apply, `os/arch.sh` and `os/ubuntu.sh` cut to the login shell and the docker group, and the CI-only scripts moved from `scripts/` to `ci/`.

## Phases

1. Docs and triage (done): README, AGENTS, TOOLS, PLAN, and TASKS match the tree, plus the per-machine identity and the alias cleanup.
2. Packages (done): Brewfile core plus host overlay Brewfiles applied by `brew bundle`, categorized package lists with a Debian path, `install-ai-clis.sh`, and node and pnpm from mise.
3. XDG layout (done): `~/.zshenv` sets the XDG variables and `ZDOTDIR`, directory links into `~/.config`, a declarative link table (`config/links`), migration of the old `~` links, the LazyVim config, the shell clones under the XDG data directory, and nvm out.
4. Installer (done): `--help`, `--only` and `--dry-run`, `os/macos.sh` trimmed to the settings that still apply, `os/*.sh` cut to the login shell and the docker group, and the scripts split into `scripts/` (setup) and `ci/` (CI and developer checks). The `NONINTERACTIVE` Homebrew bootstrap and `pacman -Syu --needed` landed with phase 2.
5. Host overlays and host-level split: one overlay per machine selected by `DOTFILES_HOST` from `hostname -s`, and the host-level settings (firewall, timezone, services, drivers) that `os/*.sh` no longer carry landing in the machines repo, with the packages that only served them leaving `packages/pacman.txt`.

Items that are not tied to a phase (clipboard fixes, overlay lint, startup timing, the ghostty, karabiner, atuin and ripgrep configs) stay in `TASKS.md`.
