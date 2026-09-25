# Setting up a new Mac

The exact sequence for a fresh Mac, start to working shell in about 10 minutes. It puts the git identity for this machine in place before the first commit, which matters most on a work machine that should not commit under the default email in the tracked config.

## 0. Before you start

- Sign in to the Mac with the account that belongs on this machine.
- Install pending macOS updates (`sudo softwareupdate -i -r`).
- Generate an SSH key on this machine if you don't already have one here (`ssh-keygen -t ed25519`) and add the public key to GitHub. Reusing a key copied from another machine defeats the point of a per-machine identity below.

## 1. Clone and set the identity first

```sh
git clone git@github.com:iagodahlem/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
cp config/git/.gitconfig.override.example ~/.gitconfig.override
```

Edit `~/.gitconfig.override` and set `user.email` to the email for this machine. `config/git/.gitconfig` includes this file last, so it overrides the name, email, and signing key baked into the tracked config. Do this before the installer runs, and definitely before the first commit: with no override file, commits on this machine silently use the default identity from the tracked config.

If this machine signs commits with a different SSH key than the default, uncomment `signingkey` in the override and point it at that key.

## 2. Run the installer

```sh
./scripts/install.sh
```

This installs packages (Homebrew formulae, casks, and fonts), symlinks config into `$HOME`, sets up Oh My Zsh and plugins, installs global Node packages, and applies macOS defaults. It prints a reminder at the end if `~/.gitconfig.override` is still missing.

Skip flags exist if you need to rerun part of it (`DOTFILES_SKIP_PACKAGES`, `DOTFILES_SKIP_DOTFILES`, `DOTFILES_SKIP_SHELL`, `DOTFILES_SKIP_NODE_GLOBALS`, `DOTFILES_SKIP_OS_DEFAULTS`). See the README.

## 3. Restart the shell and verify

Open a new terminal tab (or `exec zsh`) and check:

```sh
git config user.email      # the email for this machine
gh --version
mise --version
mosh --version
```

## Machine profile

**Installed by the shared package lists** (the same on every machine, nothing machine-specific removed): terminal (Ghostty), shell (zsh, Oh My Zsh, Powerlevel10k), editor (VS Code, neovim), git tooling (git-delta, gh), runtime manager (mise), mosh, and the rest of `packages/Brewfile`, `Caskfile`, and `Fontfile`.

**Deliberately not part of the install:**

- No secrets. Nothing in this repo reaches a password manager or any credential store. `packages/` and `config/` are static, non-secret config only.
- No account data. 1Password, Chrome, Slack, and Workflowy get installed as apps, but nothing signs them in or restores a profile. Log into each one manually with the accounts that belong on this machine.
- No git identity by default. Step 1 above is what keeps commits on this machine on the right email.

**Your call, not automated:** whether an app in the shared Caskfile belongs on a given machine at all. The installer puts every app there; leaving one signed out costs nothing, and removing it afterwards is fine. A per-host package split is planned (see `PLAN.md`).

## One machine, one identity

Each machine gets its own `~/.gitconfig.override` with the email for that machine, its own SSH key, and its own app logins. This file only covers what the dotfiles installer does and doesn't do.

`DOTFILES_HOST` is available if you want host-specific shell tweaks (`overlays/host/<name>/`, see `overlays/README.md`). It's optional and separate from the git identity step, which always uses `~/.gitconfig.override` regardless of hostname.

## What the container tests don't cover

The install flow is exercised end to end in the Ubuntu and Arch containers (`scripts/devbox-smoke.sh`), which cover OS detection, package-list parsing, symlinking, the Oh My Zsh and plugin install, and the shell boot logic shared across platforms. What that does not cover, because it is macOS-only:

- Homebrew's own bootstrap install, and every formula, cask, and font actually installing on real macOS (the container tests only exercise apt and pacman).
- `os/macos.sh` (the `defaults write`, `nvram`, and `pmset` system tweaks).
- The real Powerlevel10k prompt rendering and Nerd Font glyphs.
- `gh`, `mosh`, and `mise` working end to end on macOS (their Homebrew formulae install cleanly in principle, but that is not verified in CI).

Expect the first run on a real Mac to be the first test of those items.
