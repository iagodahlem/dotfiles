# Setting up a new work Mac

The exact sequence for a company-issued Mac, start to
working shell in about 10 minutes.

## 0. Before you start

- Sign in to the Mac with the company Apple ID / local account it shipped with, not a personal one.
- Install pending macOS updates (`sudo softwareupdate -i -r`).
- Generate an SSH key on this machine if you don't already have one here (`ssh-keygen -t ed25519`) and add the public key to GitHub. Reusing a key copied from another machine defeats the point of a per-machine identity below.

## 1. Clone and set the identity first

```sh
git clone git@github.com:iagodahlem/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
cp config/git/.gitconfig.override.example ~/.gitconfig.override
```

Edit `~/.gitconfig.override` and set `user.email` to the work address for this job. `config/git/.gitconfig` includes this file last, so it overrides the personal name/email/signing key baked into the tracked config. Do this before the installer runs, and definitely before the first commit: with no override file, commits on this machine silently use the personal Gmail identity.

If this machine signs commits with a different SSH key than the personal default, uncomment `signingkey` in the override and point it at that key.

## 2. Run the installer

```sh
./scripts/install.sh
```

This installs packages (Homebrew formulae/casks/fonts), symlinks config into `$HOME`, sets up Oh My Zsh and plugins, installs global Node packages, and applies macOS defaults. It prints a reminder at the end if `~/.gitconfig.override` is still missing.

Skip flags exist if you need to rerun part of it (`DOTFILES_SKIP_PACKAGES`, `DOTFILES_SKIP_DOTFILES`, `DOTFILES_SKIP_SHELL`, `DOTFILES_SKIP_NODE_GLOBALS`, `DOTFILES_SKIP_OS_DEFAULTS`) — see the README.

## 3. Restart the shell and verify

Open a new terminal tab (or `exec zsh`) and check:

```sh
git config user.email      # the work address, not the personal one
gh --version
mise --version
mosh --version
```

## Work machine profile

**Installed by the shared package lists** (same for every machine, nothing work-specific removed): terminal (Ghostty), shell (zsh, Oh My Zsh, Powerlevel10k), editor (VS Code, neovim), git tooling (git-delta, gh), runtime manager (mise), AI CLIs (Claude Code, Codex, Gemini CLI), mosh, and the rest of `packages/Brewfile` / `Caskfile` / `Fontfile`.

**Deliberately not part of the install:**

- No secrets. Nothing in this repo reaches Infisical, the personal password vault, or any credential store — `packages/` and `config/` are static, non-secret config only.
- No personal account data. 1Password, Chrome, Slack, and Workflowy get installed as apps, but nothing signs them in or restores a personal vault/profile. Log into each one manually with work-only accounts.
- No git identity by default. Step 1 above is what keeps commits on this machine off the personal email.

**Your call, not automated:** whether Workflowy belongs on a company-owned, company-monitored machine at all, given it's tied to the personal knowledge base. The installer puts the app there because it's in the shared Caskfile; leaving it unsigned-in costs nothing, but if you'd rather it not be installed at all on work machines, say so and the Caskfile can grow a work/personal split.

## Two machines, two identities

Each work Mac gets its own `~/.gitconfig.override` with that job's email, its own SSH key, its own browser profile, its own Slack workspace login, and no shared password vault between machines. This file only covers what the dotfiles installer does and doesn't do.

`DOTFILES_HOST` is available if you want host-specific shell tweaks later (`overlays/host/<name>/`, see `overlays/README.md`). It's optional and separate from the git identity step, which always uses `~/.gitconfig.override` regardless of hostname.

## What's untested here

The install flow was exercised end to end in the Ubuntu and Arch containers (`scripts/devbox-smoke.sh`), which cover the OS-detection, package-list parsing, symlinking, Oh My Zsh/plugin install, and shell boot logic shared across platforms. What that does NOT cover, because it's macOS-only and there's no Mac in this loop to test on:

- Homebrew's own bootstrap install, and every formula/cask/font actually installing on real macOS (the container tests only exercise apt/pacman).
- `os/macos.sh` (the `defaults write` / `nvram` / `pmset` system tweaks).
- The real Powerlevel10k prompt rendering and Nerd Font glyphs.
- `gh`, `mosh`, and `mise` actually working end to end on macOS (their Homebrew formulae install cleanly in principle, but that's not verified here).

Treat the first real Mac as the real test of those items, not this PR.
