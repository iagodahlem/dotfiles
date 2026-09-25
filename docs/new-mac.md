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
cp config/git/local.example config/git/local
```

Edit `config/git/local` and set `user.email` to the email for this machine. `config/git/config` includes it last (as `~/.config/git/local`, which is the same file once the installer links `~/.config/git` to `config/git`), so it overrides the name, email, and signing key baked into the tracked config. The file is gitignored and lives only in this checkout, so `git clean -x` would remove it. Do this before the installer runs, and definitely before the first commit: with no local file, commits on this machine silently use the default identity from the tracked config.

If this machine signs commits with a different SSH key than the default, uncomment `signingkey` in the file and point it at that key.

## 2. Run the installer

Read what it would do first. A dry run prints every step and changes nothing:

```sh
DOTFILES_HOST=<name> ./scripts/install.sh --dry-run
```

Then run it:

```sh
DOTFILES_HOST=<name> ./scripts/install.sh
```

`DOTFILES_HOST` picks the host Brewfile in `overlays/host/<name>/` that goes on top of the core one: `mac` for the personal Mac, `mini` for a work machine. Without it the installer looks for a folder named after `hostname -s`, and a machine with no Brewfile of its own just gets the core.

This installs packages (`brew bundle` on the core Brewfile, then on the host one), links config into `~/.config` (plus `~/.zshenv`, the one file that stays in `$HOME`, see the README), sets up Oh My Zsh, its plugins and tpm, installs node and pnpm through mise, installs the AI CLIs (claude, codex, gemini), syncs the LazyVim plugins, and applies macOS defaults (`TOOLS.md` lists them; key repeat applies after the next login). It prints a reminder at the end if `config/git/local` is still missing. If the mise, AI CLI or nvim step fails, the installer warns and carries on; rerun `scripts/install-mise.sh`, `scripts/install-ai-clis.sh` or `scripts/install-nvim.sh` on their own once the cause is fixed.

Ghostty reads `~/.config/ghostty/config`, a directory link to `config/ghostty/`. The tracked file is a scaffold with every key commented out, so Ghostty runs on its defaults until you set some; on macOS a file under `~/Library/Application Support/com.mitchellh.ghostty/` is read after it and wins where both set a key.

To rerun part of it, name the steps with `--only` (`./scripts/install.sh --only dotfiles --only shell`), or skip some with the variables `DOTFILES_SKIP_PACKAGES`, `DOTFILES_SKIP_DOTFILES`, `DOTFILES_SKIP_SHELL`, `DOTFILES_SKIP_MISE`, `DOTFILES_SKIP_AI_CLIS`, `DOTFILES_SKIP_NVIM` and `DOTFILES_SKIP_OS_DEFAULTS`. `./scripts/install.sh --help` lists the steps. See the README.

## 3. Restart the shell and verify

Open a new terminal tab (or `exec zsh`) and check:

```sh
git config user.email      # the email for this machine
gh --version
mise --version
node --version
pnpm --version
mosh --version
```

## Machine profile

**Installed by the shared package lists** (the same on every machine, nothing machine-specific removed): terminal (Ghostty), shell (zsh, Oh My Zsh, Powerlevel10k), editor (VS Code, neovim), git tooling (git-delta, gh), runtime manager (mise), mosh, and the rest of `packages/Brewfile`.

**Deliberately not part of the install:**

- No secrets. Nothing in this repo reaches a password manager or any credential store. `packages/` and `config/` are static, non-secret config only.
- No account data. 1Password, Chrome, and Slack get installed as apps, but nothing signs them in or restores a profile. Log into each one manually with the accounts that belong on this machine.
- No git identity by default. Step 1 above is what keeps commits on this machine on the right email.

**Your call, not automated:** whether an app in the core Brewfile belongs on a given machine at all. The installer puts every app there; leaving one signed out costs nothing, and removing it afterwards is fine. Apps that only some machines need live in the host Brewfile (`overlays/host/<name>/Brewfile`) instead.

## One machine, one identity

Each machine gets its own `config/git/local` with the email for that machine, its own SSH key, and its own app logins. This file only covers what the dotfiles installer does and doesn't do.

`DOTFILES_HOST` also selects host-specific shell tweaks (`overlays/host/<name>/`, see `overlays/README.md`). It's optional and separate from the git identity step, which always uses `config/git/local` regardless of hostname.

## What the container tests don't cover

The install flow is exercised end to end in the Ubuntu and Arch containers (`ci/devbox-smoke.sh`), which cover OS detection, package-list parsing, the link table, the Oh My Zsh, plugin and tpm install, and the shell boot logic shared across platforms. What that does not cover, because it is macOS-only:

- Homebrew's own bootstrap install, and `brew bundle` actually installing every formula, cask, and font on real macOS (the container tests only exercise apt and pacman).
- The mise, AI CLI and nvim installs: the container builds skip all three, so `scripts/install-mise.sh`, `scripts/install-ai-clis.sh` and `scripts/install-nvim.sh` are not exercised there.
- `os/macos.sh` (the `defaults write` settings and the one `sudo systemsetup` line).- The real Powerlevel10k prompt rendering and Nerd Font glyphs.
- `gh`, `mosh`, and `mise` working end to end on macOS (their Homebrew formulae install cleanly in principle, but that is not verified in CI).

Expect the first run on a real Mac to be the first test of those items.
