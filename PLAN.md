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
12. Home directory cleanup: the z database, the npm cache and the claude, codex and gemini state under the XDG directories through variables in `~/.zshenv`, macOS Terminal sessions switched off, a gitignored `config/zsh/local.zsh` for machine-private lines, and one tracked ignore for `settings.local.json`.
13. Host overlays: `DOTFILES_HOST` detected from the short hostname (`config/zsh/.zshenv`, `scripts/utils/host.sh`), the overlay of a machine found in a private overlays repo checked out at `~/.machines` (or in `overlays/host/`) and read by the shell, the git config link into `~/.config/git/host`, the host Brewfile and a host install hook that runs as the installer's `host` step, and a `private` step that clones the repo when `DOTFILES_PRIVATE_REPO` is set. The real overlays live in that private repo, and `overlays/host/example/` is the documented shape.
14. Packages round two: the desk apps and nmap in the core Brewfile, bun through mise, per-host `packages/pacman.txt` and `packages/apt.txt` from the host overlay, TinyTeX dropped as an install path, and Homebrew on `PATH` for the non-interactive shells that ssh commands run.
15. Shell startup: `ci/shell-startup.sh` (min, median and max of `zsh -i -c exit`, or a zprof top 15) against the real home or a scratch home, a `shell-startup` CI job in the Ubuntu image, the baseline and its per-block costs in `TOOLS.md`, `skip_global_compinit=1` in `.zshenv` (Ubuntu ran compinit twice) and the unused web-search plugin dropped.
16. Installer output: a banner, one confirm question before a real run from a terminal, a header and a status line per step, and a summary with the seconds, the warnings and the follow-ups (`scripts/utils/ui.sh`).

## Phases

1. Docs and triage (done): README, AGENTS, TOOLS, PLAN, and TASKS match the tree, plus the per-machine identity and the alias cleanup.
2. Packages (done): Brewfile core plus host overlay Brewfiles applied by `brew bundle`, categorized package lists with a Debian path, `install-ai-clis.sh`, and node and pnpm from mise.
3. XDG layout (done): `~/.zshenv` sets the XDG variables and `ZDOTDIR`, directory links into `~/.config`, a declarative link table (`config/links`), migration of the old `~` links, the LazyVim config, the shell clones under the XDG data directory, and nvm out.
4. Installer (done): `--help`, `--only` and `--dry-run`, `os/macos.sh` trimmed to the settings that still apply, `os/*.sh` cut to the login shell and the docker group, and the scripts split into `scripts/` (setup) and `ci/` (CI and developer checks). The `NONINTERACTIVE` Homebrew bootstrap and `pacman -Syu --needed` landed with phase 2.
5. Host overlays (done): `DOTFILES_HOST` is detected from the short hostname, and the overlay of a machine, from the private overlays repo or from `overlays/host/`, carries shell files, a git config linked into `~/.config/git/host`, a Brewfile and an install hook that runs as the installer's `host` step. Only the mechanism and an example are in this repo. The host-level settings (firewall, timezone, services, drivers) that `os/*.sh` no longer carry are for the machines repo, with the packages that only served them leaving `packages/pacman.txt`; that part stays open in `TASKS.md`.
6. Packages round two (done): the core Brewfile gains the desk apps and nmap, bun installs through mise, a host overlay may carry `packages/pacman.txt` and `packages/apt.txt` (applied after the shared lists), and `config/zsh/.zshenv` puts Homebrew on `PATH` so mosh-server, scp and git over ssh find it.
7. Shell startup (done): measured at about 88 ms on Arch with mise, 64 ms without it and 56 ms in the Ubuntu image (68 ms before `skip_global_compinit=1`); only that one line and the web-search plugin changed: mise (23% of the total) stays as `mise activate`, and no other block or single plugin reaches 10%. The options measured and not applied stay open in `TASKS.md`.
8. Installer output (done): the installer opens with a banner and one question (`--yes` skips it, a dry run never asks), prints a header and an `ok`, `skip`, `warn` or `fail` line for each step, and ends with a summary of the steps, their seconds, the warnings and what is left to do by hand. Plain text off a terminal or with `NO_COLOR`.

Items that are not tied to a phase (clipboard fixes, overlay lint, the ghostty, atuin and ripgrep configs) stay in `TASKS.md`.
