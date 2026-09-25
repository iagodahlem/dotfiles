# AGENTS

Repository context for Codex and other agents.

**Overview**
This is a personal dotfiles repo for macOS, Arch, and Debian (Raspberry Pi OS) setup. It contains static config under `config/`, installer scripts under `scripts/`, CI checks under `ci/`, OS tweaks under `os/`, and optional overrides via `overlays/`. `scripts/` holds only what a machine runs to set itself up; anything that only CI or a developer runs goes in `ci/`.

**Key Paths**

- `scripts/install.sh` is the public entrypoint (orchestration + OS detection). Its `STEPS` table lists the steps in run order (`packages`, `dotfiles`, `shell`, `mise`, `ai-clis`, `nvim`, `os-defaults`) with each one's `DOTFILES_SKIP_*` variable and script; `--help` prints it, `--only <step>` runs just that step (repeatable, skip variables ignored), and `--dry-run` sets `DOTFILES_DRY_RUN=1` for every step. Each step gets a `== <step> ==` header in both modes.
- `scripts/install-packages.sh` installs dependencies from `packages/`: `brew bundle` on `packages/Brewfile` plus the host Brewfile (`overlays/host/<DOTFILES_HOST or hostname -s>/Brewfile`) on macOS, `apt.txt` on the Debian family, `pacman.txt` and `aur.txt` on Arch.
- `scripts/install-apt-repos.sh` adds the Docker, Tailscale, eza and Azlux apt sources before `install_apt` runs `apt-get update`; it is idempotent and never prompts.
- `scripts/install-dotfiles.sh` clears the links and files the older layout kept in `$HOME`, then applies the table in `config/links` (`source  target  [os]`, paths relative to `config/` and `~`, a trailing `/` on the source for a directory link). `~/.zshenv` is the only link left in `$HOME`.
- `scripts/install-shell.sh` sources `config/zsh/.zshenv`, then clones Oh My Zsh, Powerlevel10k, the two zsh plugins and tpm into the XDG data directory at their default branches, unpinned. Rerunning it fast-forwards each clone (`git pull --ff-only`), so it is also the updater; Oh My Zsh's own updater stays off in `.zshrc`.
- `scripts/install-mise.sh` installs mise where no package list does (Debian family, `https://mise.run`), then node and pnpm from `config/mise/config.toml` (its go, ruby and rust pins wait for an explicit `mise install`), atuin and procs on the Debian family, and runs `corepack enable`.
- `scripts/install-nvim.sh` syncs the LazyVim plugins headless once `~/.config/nvim` is linked, and skips with a warning when nvim is older than 0.11.2, the minimum LazyVim needs.
- `scripts/install-ai-clis.sh` installs claude, codex and gemini from their own installers (`--update` refreshes installed ones).
- `ci/devbox-smoke.sh` builds and validates container images.
- `ci/lint-shell.sh` runs shellcheck over shell scripts.
- `ci/dry-run.sh` runs `scripts/install.sh --dry-run` on the host in a scratch home, no Docker, and checks that every step reports and that nothing lands in the home.
- `scripts/utils/os.sh` provides shared `os_id()` detection; `scripts/utils/paths.sh` puts Homebrew and `~/.local/bin` on `PATH` for installer steps; `scripts/utils/lists.sh` provides `read_list_items`, the comment-stripping reader shared by the package lists and `config/links`, and `count_list_items`.
- `scripts/utils/dry-run.sh` provides `is_dry_run`, `run` (runs a command, or in dry-run mode prints `would run: ...`), `display_path` and `describe_list` for the dry-run output. `scripts/utils/linux-defaults.sh` holds the login shell and docker group actions that `os/arch.sh` and `os/ubuntu.sh` share.
- `os/macos.sh` writes the macOS `defaults` that still apply (each line commented, listed in `TOOLS.md`), runs `sudo systemsetup -setrestartfreeze on` as its only sudo line, and restarts Finder, Dock and SystemUIServer.
- `os/ubuntu.sh` (also used for Debian and Raspberry Pi OS) and `os/arch.sh` only switch the login shell to zsh and add the user to the docker group, both guarded. Locale, timezone, services, the firewall and drivers are host-level settings that live in the machines repo.
- `containers/` contains Ubuntu/Arch devbox Dockerfiles plus shared entrypoint.
- `docker-compose.yml` defines all devbox services (`devbox`, `devbox-arch`, `devbox-isolated`).
- `overlays/` holds OS- and host-specific shell overrides and the per-host Brewfiles (see `overlays/README.md`).
- `docs/new-mac.md` is the setup sequence for a new machine, including the per-machine git identity.
- `TOOLS.md` lists everything installed and aliased, `TASKS.md` tracks open work, and `PLAN.md` lays out the next phases.

**How Config Loads**

- `~/.zshenv` (a link to `config/zsh/.zshenv`) is the only dotfile in `$HOME`. It sets the XDG variables (keeping values already exported), `ZDOTDIR=$XDG_CONFIG_HOME/zsh`, the `DOTFILES*` variables, and the redirects for oh-my-zsh, cargo, rustup, npm and tpm. It stays plain POSIX assignments because `install-shell.sh` sources it from bash.
- `~/.config/zsh` is a directory link to `config/zsh`, so `ZDOTDIR` finds `.zshrc`, `.p10k.zsh`, `.exports`, `.aliases`, `.functions` and `.bootstrap` there.
- `config/zsh/.zshrc` creates the state and cache directories, loads Oh My Zsh from `$ZSH`, then sources `config/zsh/.bootstrap`.
- `config/zsh/.bootstrap` loads base shell files (`.exports`, `.aliases`, `.functions`), then optional overlays from `overlays/os/<id>/` and `overlays/host/<name>/`, then per-tool init (`mise`, `atuin`, `brew`, `cargo`).
- `~/.config/tmux`, `~/.config/nvim`, `~/.config/zsh`, `~/.config/git`, `~/.config/ghostty` and `~/.config/mise` are directory links. The untracked `config/git/local` and `config/git/host` (reserved for the host overlays) live in the checkout, gitignored, and are what `~/.config/git/local` and `~/.config/git/host` resolve to; likewise the Debian-only `config/mise/conf.d/apt-gaps.toml` that `scripts/install-mise.sh` writes. `config/git/config` ends with `[include] path = ~/.config/git/host` and then `[include] path = ~/.config/git/local` (the per-machine identity, see `config/git/local.example` and `docs/new-mac.md`).
- Add or move a link by editing `config/links` and rerunning `scripts/install-dotfiles.sh`. Keep state a tool writes out of the linked directories: point it at `$XDG_DATA_HOME`, `$XDG_STATE_HOME` or `$XDG_CACHE_HOME` in `.zshenv` instead.

**Assumptions**

- Targets: macOS, Arch, Debian (Raspberry Pi OS). Ubuntu stays covered through the apt path and the Ubuntu container.
- This repo can be in a dirty state; do not assume a clean git worktree.
- Install scripts are destructive/system-changing (packages, symlinks, OS defaults). `scripts/install.sh --dry-run` prints what they would do and changes nothing.
- Containers are used both for test validation and optional isolated dev environments.

**Known Gaps (current state)**

- `.devcontainer/` templates are not implemented yet (parked in `TASKS.md`).
- Shell startup time has not been measured yet; that is the first open item in `TASKS.md`.
- Existing state from the older layout (`~/.oh-my-zsh`, `~/.custom`, `~/.tmux/plugins`, `~/.nvm`, `~/.cargo`, `~/.rustup`, `~/.npmrc`) is not moved by the installer, see the README.

**Roadmap (user intent)**

- Keep one unified install flow with OS/distro-specific branches.
- Keep dotfiles runnable inside Docker devboxes for client/testing contexts.
- Continue reducing shell startup overhead while preserving behavior.
- Follow the phases in `PLAN.md`: host overlays and the host-level split are next (the packages, XDG layout and installer phases are done).

**Editing Guidelines**

- Prefer minimal, portable changes.
- If changing install flows, update scripts and docs (`README.md`, `AGENTS.md`) in the same change.
- New config goes under `config/<tool>/` with a line in `config/links`; do not add a `safe_link` call to `install-dotfiles.sh`.
- A new install step is a row in the `STEPS` table in `install.sh` and a script that honours `DOTFILES_DRY_RUN=1`: route commands through `run` from `scripts/utils/dry-run.sh`, print the state it finds (already present or missing) and change nothing. A dry run must not write into `$HOME`, not even a log file; add the step's header to `ci/dry-run.sh`.
- `scripts/` is for what a machine runs to set itself up; a script only CI or a developer runs goes in `ci/`.
- Keep new files ASCII-only unless the file already contains Unicode.
- Prefer `pnpm` over `npm` for global package installs, except where a vendor documents an npm command (gemini in `install-ai-clis.sh`).
- Package lists take trailing `# comments` (`read_list_items` strips them), so keep a short comment on any entry whose name does not explain itself. Debian names go in `apt.txt`; a package that only exists in a third-party repo needs its source in `install-apt-repos.sh`.

**Principles**

1. `packages/` is the single source of truth for dependencies.
2. `scripts/install.sh` is the only public entrypoint; everything else is a sub-step.
3. `os/` holds OS-only tweaks and defaults.
4. `config/` is static config; scripts should not hardcode private config content.
5. Containers should reuse the same scripts flow (no duplicated install logic).
