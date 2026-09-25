# TASKS

Tracked tasks for dotfiles repo. Updated 2026-09-25.

## Legend

- `[ ]` not started
- `[~]` in progress
- `[x]` done

---

## Open

### Shell & Startup

- [~] **mise everywhere**: node and pnpm now install from `config/mise` on every machine (`scripts/install-mise.sh`). Left: drop nvm on every machine. The nvm shell hook (`config/nvm/.nvm`, sourced from `.bootstrap`) stays wired for now and goes in the next pass, the layout one.
- [ ] **Measure and reduce shell startup time**: add a repeatable benchmark (`zsh -i -c exit` timing) before and after changes, then lazy-load the slow init blocks. Do this after mise replaces nvm.

### Layout & Installer

- [ ] **XDG layout**: `~/.zshenv` sets the XDG variables and `ZDOTDIR`, directory links into `~/.config`, a declarative link table, migration of the old `~` links.
- [ ] **Installer hardening**: `--help` and `--dry-run`, pinned shell plugins. The `NONINTERACTIVE` Homebrew bootstrap and `pacman -Syu --needed` landed with the packages pass.
- [ ] **Trim `os/macos.sh`** to the settings that still apply. Keep: keyboard access, smart quotes and dashes and autocorrect off, save to disk, screenshots folder and PNG, Dock minimize-to-app, Finder quit menu, no desktop drive icons, hidden files, extensions, Chrome swipe off, restart on freeze. Add: Dock on the right, `KeyRepeat` 2 and `InitialKeyRepeat` 15, `killall Finder Dock SystemUIServer`. Drop the rest.
- [ ] **Host-level settings move out**: firewall, timezone, services, and drivers move out of the dotfiles to the host configuration repo; `os/*.sh` keep only `chsh` and the docker group.

### Packages

- [ ] **Move `atuin` and `procs` to `apt.txt` on Debian 13**: both are packaged there, so the mise fragment in `scripts/install-mise.sh` only matters for Debian 12 hosts. Drop it once every Debian host runs 13 or newer.

### Overlays

- [ ] **Host overlays for each machine**, selected by `DOTFILES_HOST` from `hostname -s`. The host Brewfiles (`mac`, `mini`) already fall back to `hostname -s`; the shell overlay loader in `.bootstrap` still only reads `DOTFILES_HOST`.
- [ ] **Add overlay lint coverage**: extend `scripts/lint-shell.sh` to also check `overlays/` shell files.

### Editor & Terminal

- [ ] **Tracked LazyVim config** with a headless plugin sync.
- [ ] **Clipboard fixes**: tmux `set-clipboard`, `pngpaste` on macOS.

### Documentation

- [~] **Keep README, AGENTS, TOOLS and PLAN in sync**: standing rule, update them in the same change as any install or layout edit. Synced to the current state on 2026-09-25.

## Parked

- [ ] **Switch tmux theme to tmux2k**
- [ ] **Add `.devcontainer/` templates**

## Done

- [x] **Brewfile core plus host overlays**: `packages/Brewfile` plus `overlays/host/<name>/Brewfile`, applied by `brew bundle`.
- [x] **Categorized package lists**: comments per entry in every list, and a Debian path (Raspberry Pi OS) with `install-apt-repos.sh` for the third-party sources.
- [x] **`install-ai-clis.sh`**: claude, codex and gemini install from their own installers instead of the package lists.
- [x] **Fonts in the Brewfile**: `font-meslo-lg-nerd-font` and `font-fira-code-nerd-font` are casks in `packages/Brewfile`.
- [x] **`packages/aur.txt`**: holds `google-cloud-cli` only, the AI CLIs left it for their own installers.
- [x] **Commit pending working-tree changes**
- [x] **Verify Arch container smoke parity**
