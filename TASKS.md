# TASKS

Tracked tasks for dotfiles repo. Updated 2026-09-25.

## Legend

- `[ ]` not started
- `[~]` in progress
- `[x]` done

---

## Open

### Shell & Startup

- [ ] **Decide the startup options that were measured and not applied**: `ZSH_DISABLE_COMPFIX=true` in `.zshrc` (3.0 ms on Arch, 6.3 ms in the Ubuntu image, and it turns off oh-my-zsh's check for group-writable completion directories), caching the output of `mise activate zsh`, `atuin init zsh` and `brew shellenv zsh` (about 14 ms together, with a cache to invalidate when a binary changes), and dropping the npm and docker-compose plugins (their aliases are unused, 1.2 and 0.3 ms; npm still completes the `npm` command). `ci/shell-startup.sh` stops before the first prompt, which needs about 65 ms more on a terminal (Powerlevel10k drawing it about 25 ms, mise's `precmd` hook about 14 ms): a mode that times it on a pty would cover that.

### Layout & Installer

- [~] **Host-level settings move out**: firewall, timezone, services, and drivers move out of the dotfiles to the machines repo. The `os/*.sh` half is done (they keep only `chsh` and the docker group); what is left is the machines repo carrying the locale, timezone, docker and tailscale services, paccache timer, ufw defaults and liquidctl service, and `ufw`, `liquidctl` and `pacman-contrib` leaving `packages/pacman.txt` with them.

### Packages

- [ ] **Send bun's package cache under XDG**: bun keeps its cache in `~/.bun/install/cache` unless `BUN_INSTALL_CACHE_DIR` is set, so `~/.bun` comes back with the first `bun install` even though mise provides the binary. Set the variable in `config/zsh/.zshenv` (next to the other redirects) and check where `bun add -g` writes its packages and links.
- [ ] **Move `atuin` and `procs` to `apt.txt` on Debian 13**: both are packaged there, so the mise fragment in `scripts/install-mise.sh` only matters for Debian 12 hosts. Drop it once every Debian host runs 13 or newer.

### Overlays

- [ ] **Check the zsh overlay files**: the install hooks kept under `overlays/host/` are under shellcheck, but the zsh files under `overlays/` and `config/zsh/` get no check. Add `zsh -n` over them to `ci/lint-shell.sh` and the CI job.

### Editor & Terminal

- [ ] **Clipboard fixes**: tmux `set-clipboard`, `pngpaste` on macOS.
- [ ] **Tweak the ghostty config** in `config/ghostty/config`: the scaffold is linked with every key commented out, pick the font, theme and padding.
- [ ] **Track an atuin config** (`~/.config/atuin/config.toml`) in `config/atuin/` and link it.
- [ ] **Track a ripgrep config** in `config/ripgrep/` and link it, then set `RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"` in `config/zsh/.zshenv` (ripgrep reads no file without it).
- [ ] **Commit `config/nvim/lazy-lock.json`** after the first plugin sync on the personal machine, to pin the plugin versions.

### Documentation

- [~] **Keep README, AGENTS, TOOLS and PLAN in sync**: standing rule, update them in the same change as any install or layout edit. Synced to the current state on 2026-09-25.

## Parked

- [ ] **Switch tmux theme to tmux2k**
- [ ] **Add `.devcontainer/` templates**

## Done

- [x] **Installer output**: a banner (host, OS, checkout, mode, the private overlay found, the steps that run and the ones skipped), one question before a real run from a terminal (`--yes` or `DOTFILES_YES=1` skips it, a dry run never asks), a `==> <step>` header and an `ok`, `skip`, `warn` or `fail` line per step, and a summary at the end with each step's seconds, the warnings word for word and the follow-ups that apply. The helpers are in `scripts/utils/ui.sh` (colour only on a terminal, `NO_COLOR` turns it off, bash 3.2 safe), the steps report warnings through `report_warning`, and `ci/dry-run.sh` checks the output, its plain form and the exit codes.
- [x] **Measure shell startup time**: `ci/shell-startup.sh` runs `zsh -i -c exit` N times (min, median, max) or once under zprof (`--profile`), against the real home or a scratch home, and a `shell-startup` CI job runs it in the Ubuntu image. Baseline on Arch in a scratch home with oh-my-zsh, Powerlevel10k, mise, atuin and Linuxbrew: median 89.0 ms (65.3 ms without mise), of which mise is 20.7 ms, the ten oh-my-zsh plugins 20.0 ms, compinit 7.6 ms, atuin 7.5 ms and `brew shellenv` 5.9 ms; the Ubuntu image measured 68.2 ms. Two changes came out of it: `skip_global_compinit=1` in `.zshenv` (Ubuntu's `/etc/zsh/zshrc` ran compinit before oh-my-zsh did, 68.2 to 56.3 ms in the image, nothing on Arch or Debian) and the web-search plugin dropped (unused, inside the noise). The per-block table is in `TOOLS.md`.
- [x] **Packages round two**: the desk apps (bartender, bettertouchtool, cleanshot, logi-options+, granola, notion-calendar) and nmap in the core `packages/Brewfile`, bun through mise, per-host package lists, and Homebrew on `PATH` for ssh commands. The items below are its parts.
- [x] **Per-host package lists**: a host overlay may carry `packages/pacman.txt` and `packages/apt.txt`, installed after the shared lists by `scripts/install-packages.sh` (a second `pacman -S --needed --noconfirm` call on Arch, the same candidate check as the shared list on the Debian family), through `host_overlay_dir`. `overlays/host/example/` and `overlays/README.md` show the shape, `ci/dry-run.sh` checks both paths, and TinyTeX is gone as an install path: a host that needs LaTeX lists its texlive packages in its overlay.
- [x] **bun through mise**: `bun = "latest"` in `config/mise/config.toml`, installed by `scripts/install-mise.sh` with node and pnpm. The README's migration block removes the curl-installed `~/.bun` and the TinyTeX leftovers.
- [x] **Homebrew on `PATH` for ssh commands**: `config/zsh/.zshenv` prepends `/opt/homebrew/bin` (and the Linuxbrew `bin` on Linux) when it exists, so `mosh-server`, `scp` and git over ssh find what Homebrew installed; `config/brew/.homebrew` ends with `typeset -U path` so the full `brew shellenv` in interactive shells does not double the entry.
- [x] **Home directory cleanup**: the z database, the npm cache, `~/.claude` and `~/.claude.json`, `~/.codex` and `~/.gemini` moved under the XDG directories by `ZSHZ_DATA`, `NPM_CONFIG_CACHE`, `CLAUDE_CONFIG_DIR`, `CODEX_HOME` and `GEMINI_CLI_HOME`, macOS Terminal session files switched off with `SHELL_SESSIONS_DISABLE`, a gitignored `config/zsh/local.zsh` for machine-private lines, `**/.claude/settings.local.json` in the tracked git ignore, and the README covers what stays in `~` and how to migrate an existing machine.
- [x] **Karabiner config** in `config/karabiner/karabiner.json` (one profile, three rules), linked as the `~/.config/karabiner` directory on macOS only, since Karabiner stops watching `karabiner.json` when the file is a link. Its `automatic_backups/` is gitignored.
- [x] **Installer**: `install.sh --help`, `--only <step>` and `--dry-run`, with a dry-run mode in every step (the package lists and commands, each link with its state, what it would clone or install), a `ci/dry-run.sh` job, and the legacy-layout marker removed. The `NONINTERACTIVE` Homebrew bootstrap and `pacman -Syu --needed` landed with the packages pass, and the shell clones with the layout pass.
- [x] **Trim `os/macos.sh`** to the settings that still apply: keyboard access and key repeat, no smart quotes, dashes or autocorrect, save to disk, screenshots folder and PNG, Dock on the right with minimize-to-app, Finder quit menu, no desktop drive icons, hidden files, extensions, Chrome swipe off, restart on freeze, then `killall Finder Dock SystemUIServer`.
- [x] **Scripts split**: `scripts/` keeps what a machine runs to set itself up (`install.sh`, the `install-*.sh` steps, `utils/`), and `devbox-smoke.sh`, `lint-shell.sh` and the new `dry-run.sh` live in `ci/`.
- [x] **XDG layout**: `~/.zshenv` sets the XDG variables and `ZDOTDIR`, directory links into `~/.config` from the table in `config/links`, migration of the old `~` links, and the shell plugins and tpm cloned under the XDG data directory.
- [x] **mise everywhere**: node and pnpm install from `config/mise` on every machine, the go, ruby and rust pins moved into `config/mise/config.toml`, and nvm is gone from the shell.
- [x] **Tracked LazyVim config** in `config/nvim/`, with a headless plugin sync in `scripts/install-nvim.sh`.
- [x] **Host overlays for each machine**: `DOTFILES_HOST` is detected from the short hostname, and the overlay of the machine is found by one helper (`host_overlay_dir`): the private overlays repo checked out at `~/.machines`, else `overlays/host/`. The shell loader, a `git/config` linked into `~/.config/git/host`, the host Brewfile and an `install.sh` hook that runs as the installer's `host` step all read it, and a `private` step clones the repo when `DOTFILES_PRIVATE_REPO` is set. The real overlays are in the private repo, and `overlays/host/example/` shows the shape.
- [x] **Brewfile core plus host overlays**: `packages/Brewfile` plus the `Brewfile` of the host overlay, applied by `brew bundle`.
- [x] **Categorized package lists**: comments per entry in every list, and a Debian path (Raspberry Pi OS) with `install-apt-repos.sh` for the third-party sources.
- [x] **`install-ai-clis.sh`**: claude, codex and gemini install from their own installers instead of the package lists.
- [x] **Fonts in the Brewfile**: `font-meslo-lg-nerd-font` and `font-fira-code-nerd-font` are casks in `packages/Brewfile`.
- [x] **`packages/aur.txt`**: holds `google-cloud-cli` only, the AI CLIs left it for their own installers.
- [x] **Commit pending working-tree changes**
- [x] **Verify Arch container smoke parity**
