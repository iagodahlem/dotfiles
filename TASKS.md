# TASKS

Tracked tasks for dotfiles repo. Updated 2026-09-25.

## Legend

- `[ ]` not started
- `[~]` in progress
- `[x]` done

---

## Open

### Shell & Startup

- [ ] **Measure and reduce shell startup time**: add a repeatable benchmark (`zsh -i -c exit` timing) before and after changes, then lazy-load the slow init blocks. mise has replaced nvm, so this is unblocked.

### Layout & Installer

- [~] **Host-level settings move out**: firewall, timezone, services, and drivers move out of the dotfiles to the machines repo. The `os/*.sh` half is done (they keep only `chsh` and the docker group); what is left is the machines repo carrying the locale, timezone, docker and tailscale services, paccache timer, ufw defaults and liquidctl service, and `ufw`, `liquidctl` and `pacman-contrib` leaving `packages/pacman.txt` with them.

### Packages

- [ ] **Move `atuin` and `procs` to `apt.txt` on Debian 13**: both are packaged there, so the mise fragment in `scripts/install-mise.sh` only matters for Debian 12 hosts. Drop it once every Debian host runs 13 or newer.

### Overlays

- [ ] **Host overlays for each machine**, selected by `DOTFILES_HOST` from `hostname -s`. The host Brewfiles (`mac`, `mini`) already fall back to `hostname -s`; the shell overlay loader in `.bootstrap` still only reads `DOTFILES_HOST`.
- [ ] **Add overlay lint coverage**: extend `ci/lint-shell.sh` to also check `overlays/` shell files.

### Editor & Terminal

- [ ] **Clipboard fixes**: tmux `set-clipboard`, `pngpaste` on macOS.
- [ ] **Tweak the ghostty config** in `config/ghostty/config`: the scaffold is linked with every key commented out, pick the font, theme and padding.
- [ ] **Bring the karabiner config into `config/`** from the personal Mac, and add it to `config/links`. Link the `~/.config/karabiner` directory, not `karabiner.json`, which Karabiner stops watching when it is a link.
- [ ] **Track an atuin config** (`~/.config/atuin/config.toml`) in `config/atuin/` and link it.
- [ ] **Track a ripgrep config** in `config/ripgrep/` and link it, then set `RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"` in `config/zsh/.zshenv` (ripgrep reads no file without it).
- [ ] **Commit `config/nvim/lazy-lock.json`** after the first plugin sync on the personal machine, to pin the plugin versions.

### Documentation

- [~] **Keep README, AGENTS, TOOLS and PLAN in sync**: standing rule, update them in the same change as any install or layout edit. Synced to the current state on 2026-09-25.

## Parked

- [ ] **Switch tmux theme to tmux2k**
- [ ] **Add `.devcontainer/` templates**

## Done

- [x] **Home directory cleanup**: the z database, the npm cache, `~/.claude` and `~/.claude.json`, `~/.codex` and `~/.gemini` moved under the XDG directories by `ZSHZ_DATA`, `NPM_CONFIG_CACHE`, `CLAUDE_CONFIG_DIR`, `CODEX_HOME` and `GEMINI_CLI_HOME`, macOS Terminal session files switched off with `SHELL_SESSIONS_DISABLE`, a gitignored `config/zsh/local.zsh` for machine-private lines, `**/.claude/settings.local.json` in the tracked git ignore, and the README covers what stays in `~` and how to migrate an existing machine.
- [x] **Installer**: `install.sh --help`, `--only <step>` and `--dry-run`, with a dry-run mode in every step (the package lists and commands, each link with its state, what it would clone or install), a `ci/dry-run.sh` job, and the legacy-layout marker removed. The `NONINTERACTIVE` Homebrew bootstrap and `pacman -Syu --needed` landed with the packages pass, and the shell clones with the layout pass.
- [x] **Trim `os/macos.sh`** to the settings that still apply: keyboard access and key repeat, no smart quotes, dashes or autocorrect, save to disk, screenshots folder and PNG, Dock on the right with minimize-to-app, Finder quit menu, no desktop drive icons, hidden files, extensions, Chrome swipe off, restart on freeze, then `killall Finder Dock SystemUIServer`.
- [x] **Scripts split**: `scripts/` keeps what a machine runs to set itself up (`install.sh`, the `install-*.sh` steps, `utils/`), and `devbox-smoke.sh`, `lint-shell.sh` and the new `dry-run.sh` live in `ci/`.
- [x] **XDG layout**: `~/.zshenv` sets the XDG variables and `ZDOTDIR`, directory links into `~/.config` from the table in `config/links`, migration of the old `~` links, and the shell plugins and tpm cloned under the XDG data directory.
- [x] **mise everywhere**: node and pnpm install from `config/mise` on every machine, the go, ruby and rust pins moved into `config/mise/config.toml`, and nvm is gone from the shell.
- [x] **Tracked LazyVim config** in `config/nvim/`, with a headless plugin sync in `scripts/install-nvim.sh`.
- [x] **Brewfile core plus host overlays**: `packages/Brewfile` plus `overlays/host/<name>/Brewfile`, applied by `brew bundle`.
- [x] **Categorized package lists**: comments per entry in every list, and a Debian path (Raspberry Pi OS) with `install-apt-repos.sh` for the third-party sources.
- [x] **`install-ai-clis.sh`**: claude, codex and gemini install from their own installers instead of the package lists.
- [x] **Fonts in the Brewfile**: `font-meslo-lg-nerd-font` and `font-fira-code-nerd-font` are casks in `packages/Brewfile`.
- [x] **`packages/aur.txt`**: holds `google-cloud-cli` only, the AI CLIs left it for their own installers.
- [x] **Commit pending working-tree changes**
- [x] **Verify Arch container smoke parity**
