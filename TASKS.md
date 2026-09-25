# TASKS

Tracked tasks for dotfiles repo. Updated 2026-09-24.

## Legend

- `[ ]` not started
- `[~]` in progress
- `[x]` done

---

## Open

### Shell & Startup

- [ ] **mise everywhere**: node and pnpm from `config/mise`, drop nvm on every machine.
- [ ] **Measure and reduce shell startup time**: add a repeatable benchmark (`zsh -i -c exit` timing) before and after changes, then lazy-load the slow init blocks. Do this after mise replaces nvm.

### Layout & Installer

- [ ] **XDG layout**: `~/.zshenv` sets the XDG variables and `ZDOTDIR`, directory links into `~/.config`, a declarative link table, migration of the old `~` links.
- [ ] **Installer hardening**: `--help` and `--dry-run`, `NONINTERACTIVE` Homebrew bootstrap, `pacman -Syu --needed`, pinned shell plugins.
- [ ] **Trim `os/macos.sh`** to the settings that still apply. Keep: keyboard access, smart quotes and dashes and autocorrect off, save to disk, screenshots folder and PNG, Dock minimize-to-app, Finder quit menu, no desktop drive icons, hidden files, extensions, Chrome swipe off, restart on freeze. Add: Dock on the right, `KeyRepeat` 2 and `InitialKeyRepeat` 15, `killall Finder Dock SystemUIServer`. Drop the rest.
- [ ] **Host-level settings move out**: firewall, timezone, services, and drivers move out of the dotfiles to the host configuration repo; `os/*.sh` keep only `chsh` and the docker group.

### Packages

- [ ] **Brewfile core plus host overlays**: a core Brewfile plus a Brewfile per host overlay, applied by `brew bundle`.
- [ ] **Categorized package lists**: one-line comments per entry and a Debian path (Raspberry Pi OS).
- [ ] **`install-ai-clis.sh`**: install the AI CLIs from their own installers instead of the package lists.

### Overlays

- [ ] **Host overlays for each machine**, selected by `DOTFILES_HOST` from `hostname -s`.
- [ ] **Add overlay lint coverage**: extend `scripts/lint-shell.sh` to also check `overlays/` shell files.

### Editor & Terminal

- [ ] **Tracked LazyVim config** with a headless plugin sync.
- [ ] **Clipboard fixes**: tmux `set-clipboard`, `pngpaste` on macOS.

### Documentation

- [~] **Keep README, AGENTS, TOOLS and PLAN in sync**: standing rule, update them in the same change as any install or layout edit. Synced to the current state on 2026-09-24.

## Parked

- [ ] **Switch tmux theme to tmux2k**
- [ ] **Add `.devcontainer/` templates**

## Done

- [x] **Populate `packages/Fontfile`**: `font-meslo-lg-nerd-font` is in the list.
- [x] **Populate `packages/aur.txt`**: superseded, the AI CLIs will install from their own installers and the list empties in the packages pass.
- [x] **Commit pending working-tree changes**
- [x] **Verify Arch container smoke parity**
