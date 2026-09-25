# .dotfiles

Personal dotfiles with a unified installer, overlays, and container support. Targets: macOS, Arch, Debian (Raspberry Pi OS).

[![container-ci](https://github.com/iagodahlem/dotfiles/actions/workflows/devbox-smoke.yml/badge.svg)](https://github.com/iagodahlem/dotfiles/actions/workflows/devbox-smoke.yml)

## Installation (Host)

1. (macOS only, optional) install available system updates.

```sh
sudo softwareupdate -i -r
```

2. Clone this repository.

```sh
git clone git@github.com:iagodahlem/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

3. Read what the installer would do, then run it.

```sh
./scripts/install.sh --dry-run
./scripts/install.sh
```

The installer runs nine steps in order: `private`, `packages`, `dotfiles`, `shell`, `mise`, `ai-clis`, `nvim`, `os-defaults` and `host`. `./scripts/install.sh --help` lists them with the variable that skips each one.

- `--dry-run` prints what each step would do and changes nothing: the package lists it would read with their entry counts and the commands it would run, each link and migration with its current state (missing, correct, a real file to back up, an old link to remove), what it would clone or install and whether that is already there, and the `defaults` commands. `DOTFILES_DRY_RUN=1` does the same. It reports the machine as it is now, so a step that depends on an earlier one (mise on the packages, nvim on the dotfiles links) reports what it finds today.
- `--only <step>` runs just that step, and can be repeated: `./scripts/install.sh --only dotfiles --only shell`. A step named this way runs even when its skip variable is set.

Skip variables:

- `DOTFILES_SKIP_PRIVATE=1` skip cloning or updating the private overlays repo.
- `DOTFILES_SKIP_PACKAGES=1` skip package installation.
- `DOTFILES_SKIP_DOTFILES=1` skip symlink creation.
- `DOTFILES_SKIP_SHELL=1` skip Oh My Zsh, its plugins and tpm.
- `DOTFILES_SKIP_MISE=1` skip mise, node and pnpm.
- `DOTFILES_SKIP_AI_CLIS=1` skip the AI CLI installs (claude, codex, gemini).
- `DOTFILES_SKIP_NVIM=1` skip the LazyVim plugin sync.
- `DOTFILES_SKIP_OS_DEFAULTS=1` skip OS-specific defaults/tweaks.
- `DOTFILES_SKIP_HOST=1` skip the install hook of this machine's host overlay.

Per-machine settings do not live in this repo. They live in a private repo of overlays, one folder per machine, and this repo only knows how to find and load them. To use them, set `DOTFILES_PRIVATE_REPO` to that repo in the ssh form (`git@github.com:<user>/<repo>.git`) and make sure the key of the machine can reach it: the `private` step clones it to `~/.machines` (`DOTFILES_PRIVATE` moves it) and pulls it on later runs. Without `DOTFILES_PRIVATE_REPO` the step only says private overlays are off, and everything else works with the shared config. See [Overlays](#overlays).

On macOS the packages are one core `packages/Brewfile` applied with `brew bundle`, plus the `Brewfile` in the overlay of this machine's host when it has one (see [Overlays](#overlays)). Debian, Raspberry Pi OS and Ubuntu use `packages/apt.txt`, after `scripts/install-apt-repos.sh` adds the Docker, Tailscale, eza and Azlux repositories. Arch uses `packages/pacman.txt` and `packages/aur.txt`.

`scripts/install-mise.sh` sets up mise, node and pnpm from `config/mise/config.toml`, and `scripts/install-ai-clis.sh` installs the AI CLIs from their own installers (`--update` refreshes ones already installed). If either step fails the installer warns and carries on.

Setting up a new machine? See [`docs/new-mac.md`](docs/new-mac.md) for the exact sequence, the machine profile, and the per-machine git identity step.

## Layout

`~/.zshenv` is the only dotfile in `$HOME`. It is a link to `config/zsh/.zshenv`, which sets the XDG base directories (`XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`, keeping any value already exported), points `ZDOTDIR` at `~/.config/zsh`, and redirects the tools that ignore XDG on their own (oh-my-zsh, cargo, rustup, npm, the tmux plugin manager, the z plugin, claude, codex and gemini). zsh reads `ZDOTDIR` only after `/etc/zshenv`, which is why that one file cannot move.

Everything else lives under `~/.config`, linked from `config/` by the table in `config/links`:

| Live path | Tracked source | Link |
|---|---|---|
| `~/.zshenv` | `config/zsh/.zshenv` | file |
| `~/.config/zsh` | `config/zsh/` | directory |
| `~/.config/tmux` | `config/tmux/` | directory |
| `~/.config/nvim` | `config/nvim/` | directory |
| `~/.config/git` | `config/git/` | directory |
| `~/.config/ghostty` | `config/ghostty/` | directory |
| `~/.config/mise` | `config/mise/` | directory |
| `~/.config/karabiner` | `config/karabiner/` | directory, macOS only |

`~/.config/git` is a directory link like the rest, so the two untracked files git includes by path, `local` (the identity for this machine, from `config/git/local.example`) and `host` (a link to the `git/config` of this machine's host overlay, when it has one), sit in `config/git/` in the checkout and are gitignored. `~/.config/zsh` keeps one untracked file the same way, `local.zsh` (copy `config/zsh/local.zsh.example`), which `.bootstrap` sources last for the lines that belong to one machine only, such as `TMUX_LS_ORDER`. `~/.config/mise` is a directory link too, and the `conf.d/apt-gaps.toml` fragment that `scripts/install-mise.sh` writes on the Debian family lands in `config/mise/conf.d/`, gitignored as well (mise keeps its trust records and other state under `$XDG_STATE_HOME/mise`, so nothing else of its own is written next to `config.toml`). `git clean -x` would remove these untracked files. The tools installed by `scripts/install-shell.sh` (oh-my-zsh, Powerlevel10k, the two zsh plugins, tpm) go under `$XDG_DATA_HOME`, and shell history and the completion dump under `$XDG_STATE_HOME` and `$XDG_CACHE_HOME`, so what tools write stays out of this repo (apart from `lazy-lock.json`, which the nvim plugin sync writes next to the config on purpose). `TOOLS.md` has the full tool, path and variable table.

`~/.config/karabiner` is a directory link on macOS only, and it has to be the directory: Karabiner-Elements stops noticing changes to `karabiner.json` when the file itself is a link ([the location of the configuration file](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/)). The dated backups it writes to `automatic_backups/` before it rewrites the file land in `config/karabiner/` and are gitignored. On a Mac where Karabiner is already running, restart its config watcher once after the link is made, so it watches the new location: `launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.Karabiner-Console-User-Server`.

To add a link, add a line to `config/links` and rerun `scripts/install-dotfiles.sh`:

```text
source  target  [os]
```

- `source` is a path under `config/`. A trailing `/` links the whole directory (use it when the tool owns the directory), without it only that one file is linked.
- `target` is a path under `~`, written with a leading `~/`. Missing parent directories are created, and a real file or directory already at the target is moved aside as `<target>.bak.<timestamp>`.
- `os` is `macos` or `linux`. Leave it out to link on both.
- Text after `#` is a comment.

The first run on a machine that used the older layout also clears what it left in `$HOME`: a link into this repo is removed, a real file is backed up, `~/.gitconfig.override` moves to `config/git/local`, and a real `~/.config/git` directory is cleared for the link (an identity file in it moves to `config/git/local` too, and if it holds anything besides our old links it is backed up whole). It prints one line per action and does nothing on the next run. It does not move state the tools kept elsewhere: an existing `~/.oh-my-zsh`, `~/.custom`, `~/.tmux/plugins`, `~/.nvm`, `~/.cargo` and `~/.rustup` stay where they are (delete them, or move the cargo and rustup directories to `~/.local/share/cargo` and `~/.local/share/rustup` to keep their toolchains), and npm settings in `~/.npmrc` go to `~/.config/npm/npmrc`.

### The home directory after an install

`~` holds `~/.zshenv`, the checkout (`~/.dotfiles`) and what other software owns: `~/.ssh`, which ssh and the git signing key read from there and which has no XDG variable, and on macOS `~/Library`, `~/.Trash` and `~/.CFUserTextEncoding`. What a tool would otherwise leave there as a dotfile is sent to the XDG directories by a variable in `config/zsh/.zshenv`:

- `ZSHZ_DATA` moves the z plugin's database (`~/.z`, with its `.z.lock`) to `~/.local/share/z/data`.
- `NPM_CONFIG_CACHE` moves the npm cache (`~/.npm`) to `~/.cache/npm`.
- `CLAUDE_CONFIG_DIR` moves `~/.claude` and `~/.claude.json` to `~/.config/claude`.
- `CODEX_HOME` moves `~/.codex` to `~/.local/share/codex`. codex keeps `config.toml` there next to its state, so the config sits in the data directory, and `.zshrc` creates the directory because codex exits when it is missing.
- `GEMINI_CLI_HOME` moves `~/.gemini` to `~/.local/share/gemini/.gemini`.
- `SHELL_SESSIONS_DISABLE=1` stops macOS Terminal from saving a session file per tab, which it would write to `.zsh_sessions` under `ZDOTDIR`, the checkout. History goes to `~/.local/state/zsh/history` through `HISTFILE`.

`scripts/install-ai-clis.sh` sources `.zshenv` before it runs the vendors' installers, so the first install already writes to these directories.

### Migrating an existing machine

The installer does not move state a tool already wrote, so a machine that ran these tools before keeps the old copies in `~`. Open a new shell first, because the variables come from `~/.zshenv`, and move them before the tools run again: a run creates the new directory, and `mv` would then put the old one inside it. Quit the tools first.

```sh
# zsh: once a command has run in the new shell the history file exists, and only then can the default shell's leftovers go
# (append ~/.zsh_history to it first with `cat ~/.zsh_history >> "$XDG_STATE_HOME/zsh/history"` if that history matters)
ls -l "$XDG_STATE_HOME/zsh/history" && rm -rf ~/.zsh_history ~/.zsh_sessions

# z, and the npm cache, which is rebuilt as it is used
mkdir -p "$XDG_DATA_HOME/z" && mv ~/.z "$ZSHZ_DATA" && rm -f ~/.z.lock
rm -rf ~/.npm

# claude, with the file next to its directory
mv ~/.claude "$CLAUDE_CONFIG_DIR" && mv ~/.claude.json "$CLAUDE_CONFIG_DIR/.claude.json"

# gemini
mkdir -p "$GEMINI_CLI_HOME" && mv ~/.gemini "$GEMINI_CLI_HOME/.gemini"

# codex: a new shell made $CODEX_HOME empty, and ~/.local/bin/codex links into the old ~/.codex, so relink it after the move
rmdir "$CODEX_HOME" && mv ~/.codex "$CODEX_HOME" && "$DOTFILES/scripts/install-ai-clis.sh"
```

If a directory reappears in `~` afterwards, something started the tool without going through zsh (a launcher, a GUI app that does not read the shell environment), so it never saw the variable.

## Containers

### Docker (Ubuntu)

```sh
docker build -f containers/Dockerfile -t dotfiles-devbox .
docker run --rm -it dotfiles-devbox
```

### Docker (Arch)

```sh
docker build -f containers/Dockerfile.arch -t dotfiles-devbox-arch .
docker run --rm -it dotfiles-devbox-arch
```

### Compose services (single file)

- `devbox`: Ubuntu dev shell with bind-mounted workspace (`DOTFILES_WORKSPACE`, default `.`).
- `devbox-arch`: Arch dev shell (`--profile arch`).
- `devbox-isolated`: Ubuntu dev shell with isolated named volume workspace (`--profile isolated`).

Examples:

```sh
docker compose run --rm devbox
```

```sh
DOTFILES_WORKSPACE=.. docker compose run --rm devbox
```

```sh
docker compose --profile arch run --rm devbox-arch
```

```sh
docker compose --profile isolated run --rm devbox-isolated
```

Use `DOTFILES_CONTAINER_MINIMAL=1` to skip Oh My Zsh/plugins during image build. The images also skip the private overlays, mise, AI CLI, nvim and host steps; run `scripts/install-mise.sh`, `scripts/install-ai-clis.sh` and `scripts/install-nvim.sh` inside a container to add them.

## Architecture

```text
.
├── packages/                # Source of truth for dependencies
│   ├── Brewfile             # Homebrew core (formulae, casks, fonts), brew bundle syntax
│   ├── apt.txt              # Debian / Raspberry Pi OS / Ubuntu
│   ├── pacman.txt           # Arch
│   └── aur.txt              # Arch (AUR)
├── scripts/                 # what a machine runs to set itself up
│   ├── install.sh           # main entrypoint (--help, --only, --dry-run)
│   ├── install-private.sh   # clones or pulls the private overlays repo
│   ├── install-packages.sh
│   ├── install-apt-repos.sh # Docker, Tailscale, eza and Azlux apt sources
│   ├── install-dotfiles.sh # reads config/links
│   ├── install-shell.sh     # oh-my-zsh, Powerlevel10k, zsh plugins, tpm (cloned, pulled on rerun)
│   ├── install-mise.sh      # mise, node, pnpm
│   ├── install-ai-clis.sh   # claude, codex, gemini
│   ├── install-nvim.sh      # LazyVim plugin sync
│   └── utils/               # os.sh, host.sh, paths.sh, lists.sh, dry-run.sh, linux-defaults.sh
├── ci/                      # what CI and a developer run, never a machine being set up
│   ├── dry-run.sh
│   ├── devbox-smoke.sh
│   └── lint-shell.sh
├── os/
│   ├── macos.sh
│   ├── ubuntu.sh            # also used for Debian
│   └── arch.sh
├── config/
│   ├── atuin/.atuin
│   ├── brew/.homebrew
│   ├── cargo/.cargo
│   ├── ghostty/config       # scaffold, every key commented out
│   ├── git/                 # config, ignore, message, local.example (local and host stay untracked)
│   ├── karabiner/           # karabiner.json (automatic_backups stays untracked), macOS only
│   ├── links                # link table read by install-dotfiles.sh
│   ├── mise/                # .mise, config.toml (conf.d stays untracked)
│   ├── npm/.npm
│   ├── nvim/                # LazyVim: init.lua, lua/, stylua.toml, .neoconf.json
│   ├── tmux/tmux.conf
│   └── zsh/                 # .zshenv, .zshrc, .bootstrap, .exports, .aliases, .functions, .p10k.zsh, local.zsh.example (local.zsh stays untracked)
├── containers/
│   ├── Dockerfile
│   ├── Dockerfile.arch
│   └── entrypoint.sh
├── overlays/
│   ├── README.md
│   ├── os/                  # arch, debian, macos, ubuntu (zsh/.aliases)
│   └── host/                # example, the shape of a host overlay (real ones live in a private repo)
├── docs/
│   └── new-mac.md
├── .github/workflows/
│   └── devbox-smoke.yml
├── docker-compose.yml
├── .dockerignore
├── .editorconfig
├── .gitignore
├── README.md
├── AGENTS.md
├── TOOLS.md
├── TASKS.md
└── PLAN.md
```

## Runtime Flow

- `scripts/install.sh` runs the install steps in the order of its `STEPS` table, one `== <step> ==` header each, and passes `--dry-run` on to them as `DOTFILES_DRY_RUN=1`. A step that fetches from the network (`private`, `mise`, `ai-clis`, `nvim`, `host`) warns on failure and lets the rest carry on.
- `scripts/utils/os.sh` resolves `os_id` (`macos`, `arch`, `debian`, `raspbian`, `ubuntu`, or `unknown`). `debian`, `raspbian` and `ubuntu` share the apt list and `os/ubuntu.sh`. `DOTFILES_OS_ID` overrides the detection for tests, for example `DOTFILES_OS_ID=macos scripts/install-dotfiles.sh` in a scratch `$HOME` on Linux to apply the `macos` entries of `config/links`.
- `scripts/utils/host.sh` names this machine (`host_id`, `DOTFILES_HOST` or the short hostname) and finds its overlay (`host_overlay_dir`), for the installer scripts and for `config/zsh/.bootstrap` alike.
- `scripts/utils/dry-run.sh` is what every step shares for the dry run: `is_dry_run`, and `run`, which runs a command or prints it. `scripts/utils/linux-defaults.sh` holds the login shell and docker group actions that `os/arch.sh` and `os/ubuntu.sh` share.
- `scripts/install-private.sh` runs first: it clones `DOTFILES_PRIVATE_REPO` to `DOTFILES_PRIVATE` (`~/.machines`) with `git clone --depth 1`, or runs `git pull --ff-only` when that is already a checkout, so the overlay of this machine is there for the steps after it. It only prints a line when `DOTFILES_PRIVATE_REPO` is not set, and a failure only warns.
- `scripts/install-packages.sh` installs from `packages/` per OS: `brew bundle` on the core Brewfile and then the host Brewfile on macOS, one `apt-get install` on the Debian family, one `pacman -Syu --needed` on Arch.
- `scripts/install-apt-repos.sh` adds the third-party apt sources `install_apt` needs before `apt-get update`, and skips any that is already configured.
- `scripts/install-dotfiles.sh` clears the links and files the older layout kept in `$HOME`, then applies the table in `config/links` (see [Layout](#layout)). A real file or directory in the way is backed up as `*.bak.<timestamp>`.
- `scripts/install-shell.sh` sources `config/zsh/.zshenv`, then clones Oh My Zsh, Powerlevel10k, the two zsh plugins and tpm into the XDG data directory at their default branches, unpinned. Rerunning it fast-forwards each clone (`git pull --ff-only`), so it is also the updater, and it warns and leaves a clone alone when the pull fails (offline, or a clone left at a commit by an earlier revision of the installer: delete it and rerun). Oh My Zsh's own updater stays off in `.zshrc`, so there is one updater.
- `scripts/install-mise.sh` installs mise where the package list does not (Debian family, from `https://mise.run`), then node and pnpm from `config/mise/config.toml` (its go, ruby and rust pins wait for an explicit `mise install`), plus atuin and procs on the Debian family, and runs `corepack enable`.
- `scripts/install-nvim.sh` runs `nvim --headless "+Lazy! sync" +qa` once `~/.config/nvim` is linked, and skips with a warning when nvim is missing or older than 0.11.2, the minimum LazyVim needs. The sync writes `config/nvim/lazy-lock.json`, so commit it to pin the plugin versions.
- `scripts/install-ai-clis.sh` installs claude, codex and gemini from their own installers, skipping any already on `PATH` unless `--update` is passed. It sources `config/zsh/.zshenv` first, so they write their state under the XDG directories from the first run.
- The `host` step, the last one, runs the `install.sh` of this machine's host overlay when there is one, with `DOTFILES_DRY_RUN=1` on a dry run, and a failure only warns.
- `os/macos.sh` writes the macOS `defaults` that still apply on a current Mac (save to disk, keyboard access and key repeat, no smart quotes, dashes or autocorrect, screenshots in `~/Documents/Screenshots` as PNG, the Dock on the right, Finder and the hidden files and extensions), then restarts Finder, Dock and SystemUIServer. `sudo systemsetup -setrestartfreeze on` is its one line that needs sudo, and a failure there only warns. Key repeat applies after the next login. `TOOLS.md` lists every setting.
- `os/ubuntu.sh` and `os/arch.sh` switch the login shell to zsh and add the user to the docker group, each guarded so a refusal only warns. Locale, timezone, services, the firewall and drivers are host-level settings and live in the machines repo.

## Overlays

Overlays provide optional OS- and host-specific customizations without separate repositories. `overlays/README.md` has the details.

- OS overlay: `overlays/os/<id>/` where `<id>` matches `os_id`, shell files only.
- Host overlay: one folder per machine, named after its short hostname in lower case (`DOTFILES_HOST` picks another). It is `<name>/dotfiles/` in the private overlays repo, checked out at `~/.machines`, and `overlays/host/<name>/` in this repo is only the fallback and the documented shape. The real overlays are private, so they are not in this repo.
- An overlay may hold `zsh/.exports`, `zsh/.aliases`, `zsh/.functions`, `zsh/.zshrc.local` and `zsh/.bootstrap` (read by `config/zsh/.bootstrap`), a `git/config` (linked as `config/git/host`), a `Brewfile` (applied on macOS) and an `install.sh` (the `host` step). Every file is optional.

Example:

```text
overlays/os/ubuntu/zsh/.aliases
overlays/host/example/zsh/.exports
```

## CI and Smoke

`scripts/` holds only what a machine runs to set itself up: `install.sh`, the `install-*.sh` steps and `utils/`. What only CI or a developer runs lives in `ci/`.

- `ci/lint-shell.sh` runs shellcheck on installer/container shell scripts.
- `ci/dry-run.sh` runs `scripts/install.sh --dry-run` on the host, no Docker, with a scratch `$HOME`. It checks that every step prints its header, that `--help` and `--only` work, that a private overlay is found before one in the checkout, and that nothing lands in the home directory. Run it locally the same way.
- `ci/devbox-smoke.sh` builds a target Dockerfile and verifies non-root login, the `~/.zshenv` and `~/.config` links, and that `ZDOTDIR` is `~/.config/zsh`.
- CI runs shellcheck in a dedicated container image, the installer dry run on the runner, and smoke tests for Ubuntu + Arch Dockerfiles. The container builds keep `DOTFILES_SKIP_MISE=1 DOTFILES_SKIP_AI_CLIS=1`, along with the packages, nvim, OS defaults, host and private skips.

## Notes

- Install scripts are intentionally stateful and can modify system settings/packages.
- `TOOLS.md` lists everything the repo installs and aliases, `TASKS.md` tracks open work, and `PLAN.md` lays out the next phases.

## Thanks

We can learn a lot about productivity just exploring the way people work every day. Personally, I got highly inspired by [Holman](https://github.com/holman/dotfiles), [Mathias Bynens](https://github.com/mathiasbynens/dotfiles), [Deny Dias](https://github.com/denydias/dotfiles) and by this [setup and readme](https://github.com/diessica/dotfiles).

I can't agree more with [Holman](https://github.com/holman)'s thoughts on dotfiles: [dotfiles are meant to be forked](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked).

## License

[MIT License](http://iagodahlem.mit-license.org/) © Iago Dahlem
