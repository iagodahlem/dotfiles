# Setting up a new Mac

The exact sequence for a fresh Mac, start to working shell in about 10 minutes. It puts the git identity for this machine in place before the first commit, which matters most on a work machine that should not commit under the default email in the tracked config.

## 0. Before you start

- Sign in to the Mac with the account that belongs on this machine.
- Install pending macOS updates (`sudo softwareupdate -i -r`).
- Generate an SSH key on this machine if you don't already have one here (`ssh-keygen -t ed25519`) and add the public key to GitHub. Reusing a key copied from another machine defeats the point of a per-machine identity below.
- Make sure that key can also reach the private repo of host overlays, if you keep one (step 2). The installer clones it over ssh, so a key that GitHub accepts for this machine but not for that repo fails the clone with a warning, and the machine gets the shared config only.

## 1. Clone and set the identity first

```sh
git clone git@github.com:iagodahlem/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
cp config/git/local.example config/git/local
```

Edit `config/git/local` and set `user.email` to the email for this machine. `config/git/config` includes it last (as `~/.config/git/local`, which is the same file once the installer links `~/.config/git` to `config/git`), so it overrides the name, email, and signing key baked into the tracked config. The file is gitignored and lives only in this checkout, so `git clean -x` would remove it. Do this before the installer runs, and definitely before the first commit: with no local file, commits on this machine silently use the default identity from the tracked config.

If this machine signs commits with a different SSH key than the default, uncomment `signingkey` in the file and point it at that key.

Shell lines that belong to this machine only (`TMUX_LS_ORDER`, for example) go in `config/zsh/local.zsh` the same way: copy `config/zsh/local.zsh.example` and edit it. It is optional, gitignored, and `.bootstrap` sources it last.

## 2. Pull in the private overlays, then run the installer

The settings that belong to one machine are not in this repo. They live in a private repo of overlays with one folder per machine, and the overlay of this machine is the `<name>/dotfiles/` folder in it, where `<name>` is the short hostname in lower case (`hostname -s`; set `DOTFILES_HOST` to use another). Point the installer at that repo, in the ssh form, and let its first step, `private`, clone it to `~/.machines`:

```sh
export DOTFILES_PRIVATE_REPO=git@github.com:<user>/<repo>.git
./scripts/install.sh --only private
```

It pulls the repo instead on a machine that already has it, and does nothing but say private overlays are off while `DOTFILES_PRIVATE_REPO` is empty. `DOTFILES_PRIVATE` moves the checkout elsewhere. A dry run does not clone, so do this before the dry run to have the overlay of this machine in the report.

Read what the installer would do. A dry run prints every step and changes nothing:

```sh
./scripts/install.sh --dry-run
```

Then run it:

```sh
./scripts/install.sh
```

The overlay of this machine, when there is one, adds its Brewfile on top of the core one, a git config, shell files and an install hook (see `overlays/README.md`). A machine with no overlay, or with the private repo left out, just gets the shared config.

This installs packages (`brew bundle` on the core Brewfile, then on the one in the host overlay), links config into `~/.config` (plus `~/.zshenv`, the one file that stays in `$HOME`, see the README), sets up Oh My Zsh, its plugins and tpm, installs node, pnpm and bun through mise, installs the AI CLIs (claude, codex, gemini), syncs the LazyVim plugins, and applies macOS defaults (`TOOLS.md` lists them; key repeat applies after the next login). It runs the install hook of the host overlay last, when there is one. It prints a reminder at the end if `config/git/local` is still missing. If the private, mise, AI CLI, nvim or host step fails, the installer warns and carries on; rerun `scripts/install-private.sh`, `scripts/install-mise.sh`, `scripts/install-ai-clis.sh` or `scripts/install-nvim.sh` on their own once the cause is fixed, or the failed step with `./scripts/install.sh --only <step>`.

Ghostty reads `~/.config/ghostty/config`, a directory link to `config/ghostty/`. The tracked file is a scaffold with every key commented out, so Ghostty runs on its defaults until you set some; on macOS a file under `~/Library/Application Support/com.mitchellh.ghostty/` is read after it and wins where both set a key.

Karabiner-Elements reads `~/.config/karabiner/karabiner.json`, and `~/.config/karabiner` is a directory link to `config/karabiner/` that only a Mac gets, so the remaps come with the links. Karabiner still needs its permissions granted by hand from System Settings on the first launch: Accessibility (Privacy & Security, which also covers Input Monitoring from Karabiner-Elements 16.0.0), the driver extension (Login Items & Extensions), and the background items in General > Login Items. See the [required macOS settings](https://karabiner-elements.pqrs.org/docs/manual/misc/required-macos-settings/).

To rerun part of it, name the steps with `--only` (`./scripts/install.sh --only dotfiles --only shell`), or skip some with the variables `DOTFILES_SKIP_PRIVATE`, `DOTFILES_SKIP_PACKAGES`, `DOTFILES_SKIP_DOTFILES`, `DOTFILES_SKIP_SHELL`, `DOTFILES_SKIP_MISE`, `DOTFILES_SKIP_AI_CLIS`, `DOTFILES_SKIP_NVIM`, `DOTFILES_SKIP_OS_DEFAULTS` and `DOTFILES_SKIP_HOST`. `./scripts/install.sh --help` lists the steps. See the README.

## 3. Restart the shell and verify

Open a new terminal tab (or `exec zsh`) and check:

```sh
git config user.email      # the email for this machine
gh --version
mise --version
node --version
pnpm --version
bun --version
mosh --version
```

`mosh` needs `mosh-server` on the Mac when you connect to it, and ssh runs that command in a shell that reads only `~/.zshenv`. From another machine, `ssh <this-mac> 'command -v mosh-server'` should print the Homebrew path (`/opt/homebrew/bin/mosh-server`); `.zshenv` puts that directory on `PATH` for it. Logi Options+ needs a reboot to finish installing, which its cask says at the end of the install.

## Machine profile

**Installed by the shared package lists** (the same on every machine, nothing machine-specific removed): terminal (Ghostty), shell (zsh, Oh My Zsh, Powerlevel10k), editor (VS Code, neovim), git tooling (git-delta, gh), runtime manager (mise), mosh, and the rest of `packages/Brewfile`.

**Deliberately not part of the install:**

- No secrets. Nothing in this repo reaches a password manager or any credential store. `packages/` and `config/` are static, non-secret config only.
- No account data. 1Password, Chrome, and Slack get installed as apps, but nothing signs them in or restores a profile. Log into each one manually with the accounts that belong on this machine, and enter the licenses of the paid ones (Bartender, BetterTouchTool, CleanShot) yourself.
- No git identity by default. Step 1 above is what keeps commits on this machine on the right email.

**Your call, not automated:** whether an app in the core Brewfile belongs on a given machine at all. The installer puts every app there; leaving one signed out costs nothing, and removing it afterwards is fine. Apps that only some machines need live in the `Brewfile` of the host overlay instead.

## One machine, one identity

Each machine gets its own `config/git/local` with the email for that machine, its own SSH key, and its own app logins. This file only covers what the dotfiles installer does and doesn't do.

The host overlay also carries host-specific shell tweaks and git settings (see `overlays/README.md`). It's optional and separate from the git identity step, which always uses `config/git/local` regardless of hostname: the overlay's `git/config` is linked as `config/git/host`, which git reads before `config/git/local`, so the identity still wins.

## What the container tests don't cover

The install flow is exercised end to end in the Ubuntu and Arch containers (`ci/devbox-smoke.sh`), which cover OS detection, package-list parsing, the link table, the Oh My Zsh, plugin and tpm install, and the shell boot logic shared across platforms. What that does not cover, because it is macOS-only:

- Homebrew's own bootstrap install, and `brew bundle` actually installing every formula, cask, and font on real macOS (the container tests only exercise apt and pacman).
- The private overlays clone, the mise, AI CLI and nvim installs and the host hook: the container builds skip all of them, so `scripts/install-private.sh`, `scripts/install-mise.sh`, `scripts/install-ai-clis.sh` and `scripts/install-nvim.sh` are not exercised there. `ci/dry-run.sh` covers the private step and the host hook as dry runs.
- `os/macos.sh` (the `defaults write` settings and the one `sudo systemsetup` line).- The real Powerlevel10k prompt rendering and Nerd Font glyphs.
- `gh`, `mosh`, and `mise` working end to end on macOS (their Homebrew formulae install cleanly in principle, but that is not verified in CI).

Expect the first run on a real Mac to be the first test of those items.
