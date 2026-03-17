# TASKS

Tracked tasks for dotfiles repo. Updated 2026-03-17.

## Legend

- `[ ]` not started
- `[~]` in progress
- `[x]` done

---

## Theme & Appearance

- [ ] **Switch tmux theme to tmux2k** — Replace Dracula plugin with [tmux2k](https://github.com/2KAbhishek/tmux2k). Remove `dracula/tmux` plugin + custom Dracula color variables (lines 28, 33-51 in `.tmux.conf`). Add tmux2k plugin via TPM and configure theme/plugins/colors. Update nested-session status-left bindings to use tmux2k's color scheme instead of hardcoded Dracula hex values.
- [ ] **Populate `packages/Fontfile`** — Add Nerd Font cask(s) (e.g. `font-jetbrains-mono-nerd-font`) needed for tmux2k powerline glyphs and Powerlevel10k.

## OS Defaults

- [ ] **Implement `os/ubuntu.sh`** — Add safe, reversible Ubuntu defaults (timezone, locale, apt unattended-upgrades, sysctl tweaks, ufw baseline). Keep parity with what `os/macos.sh` covers.
- [ ] **Implement `os/arch.sh`** — Add safe Arch defaults (locale-gen, systemd services enable, makepkg flags, pacman color/parallel downloads).
- [ ] **Populate `packages/aur.txt`** — Decide which AUR packages (if any) should be installed by default on Arch.

## Containers & Dev Environments

- [ ] **Add `.devcontainer/` templates** — Create `devcontainer.json` variants: one bind-mount (reuses `containers/Dockerfile`), one isolated volume. Wire features and extensions list.
- [ ] **Verify Arch container smoke parity** — Ensure `devbox-smoke.sh` matrix covers the same assertions for Arch as Ubuntu (non-root, symlinks, shell login).

## Shell & Startup

- [ ] **Measure and reduce shell startup time** — Add a repeatable benchmark (`zsh -i -c exit` timing) before/after changes. Target: identify and lazy-load slow init blocks (asdf, nvm, cargo).
- [ ] **Consolidate asdf and nvm init** — Both are loaded on every shell start. Evaluate lazy-loading nvm or switching fully to asdf for Node.

## CI & Quality

- [ ] **Commit pending working-tree changes** — Stage and commit the current batch of modified/new files (Dockerfiles, compose, smoke script, lint script, docs).
- [ ] **Add overlay lint coverage** — Extend `scripts/lint-shell.sh` to also check `overlays/` shell files.

## Documentation

- [ ] **Keep README/AGENTS/PLAN in sync** — After completing tasks above, update all three docs to reflect new state.
