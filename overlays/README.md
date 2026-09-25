# Overlays

Overlays provide optional, OS- or host-specific tweaks without separate repositories.

## Structure

- `overlays/os/<id>/` for OS-specific shell config, where `<id>` is the value of `os_id` (`macos`, `ubuntu`, `debian`, `arch`; older 32-bit Raspberry Pi OS reports `raspbian` and has no overlay of its own)
- a host overlay for one machine, named after its short hostname in lower case: `<name>/dotfiles/` in a private overlays repo, or `overlays/host/<name>/` in this one

The real host overlays live in a private repo, not here. This repo only holds the mechanism that finds and loads them, and `overlays/host/example/` as the documented shape of an overlay.

## The host is detected

`config/zsh/.zshenv` exports `DOTFILES_HOST` as the short hostname in lower case: `$HOST` in zsh, which forks nothing, and `uname -n` where that is not set, since `hostname` is not installed everywhere. `scripts/utils/host.sh` gives the installer scripts the same name as `host_id`. A machine whose hostname matches an overlay needs nothing set, and a machine with no overlay just gets the shared config.

To use another overlay, export `DOTFILES_HOST=<name>` before the installer or the shell. An exported value is used as it is, so write it in lower case.

## Where the overlay is looked for

`host_overlay_dir` in `scripts/utils/host.sh` finds the overlay directory of this machine, and everything that reads one goes through it: the zsh loader in `config/zsh/.bootstrap`, the git link made by `scripts/install-dotfiles.sh`, the host Brewfile and package lists in `scripts/install-packages.sh` and the `host` step of `scripts/install.sh`. It takes the first of these that exists:

| Order | Directory | When it exists |
|---|---|---|
| 1 | `$DOTFILES_PRIVATE/<name>/dotfiles/` | the private overlays repo is checked out (`~/.machines` by default) and has a folder for this host |
| 2 | `overlays/host/<name>/` | this repo has an overlay of that name |
| none | | the host gets the shared config only |

The first directory found is the whole overlay: the files of the second are not merged into it, so a private overlay with no `git/config` does not fall back to the public one's.

## The private overlays repo

It is any git repo with one folder per machine, and the overlay of a machine in a `dotfiles/` folder inside it, next to whatever else that machine's folder holds:

```text
<name>/dotfiles/    the overlay of <name>, the same shape as overlays/host/example/
```

The `private` step of `scripts/install.sh`, the first one, puts it in place. Set `DOTFILES_PRIVATE_REPO` to the repo in the ssh form and make sure the key of the machine can reach it:

- not a git checkout at `$DOTFILES_PRIVATE` (`~/.machines` by default): `git clone --depth 1 "$DOTFILES_PRIVATE_REPO" "$DOTFILES_PRIVATE"`
- already a checkout: `git -C "$DOTFILES_PRIVATE" pull --ff-only`, which only warns when it cannot update
- `DOTFILES_PRIVATE_REPO` empty and no checkout: one line saying private overlays are off, and the install carries on with the shared config
- a directory somebody filled by hand is used as it is

`DOTFILES_SKIP_PRIVATE=1` skips the step, `--only private` runs just it and `--dry-run` prints the clone or the pull. A failure only warns, like the other steps that fetch from the network. The address of the repo is never written in this repo.

## What an overlay may contain

Every file is optional.

| File | Read by | Use |
|---|---|---|
| `zsh/.exports`, `zsh/.aliases`, `zsh/.functions` | `load_overlay` in `config/zsh/.bootstrap`, after the shared files, in that order | exports, aliases and functions for this OS or host |
| `zsh/.zshrc.local` | the same loader, after those | shell lines that are none of the three, such as a completion source or a `setopt` |
| `zsh/.bootstrap` | the same loader, last | anything that has to run after all of the above |
| `git/config` | `scripts/install-dotfiles.sh`, host overlays only | git settings for this host, linked as `config/git/host` and included by `config/git/config`; the identity stays in `config/git/local` |
| `Brewfile` | `scripts/install-packages.sh` on macOS, host overlays only | extra formulae and casks in `brew bundle` syntax, applied after `packages/Brewfile`; a Brewfile with no entries is skipped |
| `packages/pacman.txt` | `scripts/install-packages.sh` on Arch, host overlays only | extra pacman packages, one per line with `#` comments like `packages/pacman.txt`, installed after the shared list in a second `pacman -S --needed --noconfirm` call; a list with no entries is skipped, and a call that fails (a name pacman does not know) warns and lets the rest of the step carry on |
| `packages/apt.txt` | `scripts/install-packages.sh` on the Debian family, host overlays only | extra apt packages in the same format, installed after the shared list with the same candidate check: a package this release has no candidate for is skipped with a warning. Only what apt already knows, since `scripts/install-apt-repos.sh` adds the third-party sources for the shared list only |
| `install.sh` | `scripts/install.sh`, host overlays only, as its `host` step, the last one | setup only this machine needs, an executable bash script with `set -euo pipefail`; safe to rerun, and it honours `DOTFILES_DRY_RUN=1` (`scripts/utils/dry-run.sh` has `is_dry_run`) |

TinyTeX is not an install path: a machine that needs LaTeX lists its texlive packages in `packages/pacman.txt` or `packages/apt.txt`.

The shell loader reads only the `zsh/` files and ignores everything else under an overlay. `DOTFILES_SKIP_HOST=1` skips the `host` step, `--only host` runs just it, and `--dry-run` reaches the hook as `DOTFILES_DRY_RUN=1`. A hook that fails only warns, like the other steps that fetch from the network. The hooks under `overlays/host/` are linted with the other shell scripts, the ones in a private repo are not.

## Example

`overlays/host/example/` has one file of each kind, each with a single commented line, and `DOTFILES_HOST=example` loads it anywhere:

```text
Brewfile
git/config
install.sh
packages/apt.txt
packages/pacman.txt
zsh/.aliases
zsh/.bootstrap
zsh/.exports
zsh/.functions
zsh/.zshrc.local
```

To add a machine, create `<name>/dotfiles/` in the private repo with only the files it needs. Nothing has to be registered anywhere. To keep an overlay in this repo instead, create `overlays/host/<name>/` the same way, where it is used only when the private repo has no folder for the host.
