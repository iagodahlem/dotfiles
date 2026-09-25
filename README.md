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

3. Run the unified installer.

```sh
./scripts/install.sh
```

Optional installer flags:

- `DOTFILES_SKIP_PACKAGES=1` skip package installation.
- `DOTFILES_SKIP_DOTFILES=1` skip symlink creation.
- `DOTFILES_SKIP_SHELL=1` skip Oh My Zsh, its plugins and tpm.
- `DOTFILES_SKIP_MISE=1` skip mise, node and pnpm.
- `DOTFILES_SKIP_AI_CLIS=1` skip the AI CLI installs (claude, codex, gemini).
- `DOTFILES_SKIP_NVIM=1` skip the LazyVim plugin sync.
- `DOTFILES_SKIP_OS_DEFAULTS=1` skip OS-specific defaults/tweaks.

On macOS the packages are one core `packages/Brewfile` applied with `brew bundle`, plus the Brewfile of the host named by `DOTFILES_HOST` (default `hostname -s`) in `overlays/host/<name>/`. For example, `DOTFILES_HOST=mac ./scripts/install.sh` also applies `overlays/host/mac/Brewfile`. Debian, Raspberry Pi OS and Ubuntu use `packages/apt.txt`, after `scripts/install-apt-repos.sh` adds the Docker, Tailscale, eza and Azlux repositories. Arch uses `packages/pacman.txt` and `packages/aur.txt`.

`scripts/install-mise.sh` sets up mise, node and pnpm from `config/mise/config.toml`, and `scripts/install-ai-clis.sh` installs the AI CLIs from their own installers (`--update` refreshes ones already installed). If either step fails the installer warns and carries on.

Setting up a new machine? See [`docs/new-mac.md`](docs/new-mac.md) for the exact sequence, the machine profile, and the per-machine git identity step.

## Layout

`~/.zshenv` is the only dotfile in `$HOME`. It is a link to `config/zsh/.zshenv`, which sets the XDG base directories (`XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`, keeping any value already exported), points `ZDOTDIR` at `~/.config/zsh`, and redirects the tools that ignore XDG on their own (oh-my-zsh, cargo, rustup, npm, the tmux plugin manager). zsh reads `ZDOTDIR` only after `/etc/zshenv`, which is why that one file cannot move.

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

`~/.config/git` is a directory link like the rest, so the two untracked files git includes by path, `local` (the identity for this machine, from `config/git/local.example`) and `host` (which the host overlays will link in), sit in `config/git/` in the checkout and are gitignored. `~/.config/mise` is a directory link too, and the `conf.d/apt-gaps.toml` fragment that `scripts/install-mise.sh` writes on the Debian family lands in `config/mise/conf.d/`, gitignored as well (mise keeps its trust records and other state under `$XDG_STATE_HOME/mise`, so nothing else of its own is written next to `config.toml`). `git clean -x` would remove these untracked files. The tools installed by `scripts/install-shell.sh` (oh-my-zsh, Powerlevel10k, the two zsh plugins, tpm) go under `$XDG_DATA_HOME`, and shell history and the completion dump under `$XDG_STATE_HOME` and `$XDG_CACHE_HOME`, so what tools write stays out of this repo (apart from `lazy-lock.json`, which the nvim plugin sync writes next to the config on purpose). `TOOLS.md` has the full tool, path and variable table.

To add a link, add a line to `config/links` and rerun `scripts/install-dotfiles.sh`:

```text
source  target  [os]
```

- `source` is a path under `config/`. A trailing `/` links the whole directory (use it when the tool owns the directory), without it only that one file is linked.
- `target` is a path under `~`, written with a leading `~/`. Missing parent directories are created, and a real file or directory already at the target is moved aside as `<target>.bak.<timestamp>`.
- `os` is `macos` or `linux`. Leave it out to link on both.
- Text after `#` is a comment.

The first run on a machine that used the older layout also clears what it left in `$HOME`: a link into this repo is removed, a real file is backed up, `~/.gitconfig.override` moves to `config/git/local`, and a real `~/.config/git` directory is cleared for the link (an identity file in it moves to `config/git/local` too, and if it holds anything besides our old links it is backed up whole). It prints one line per action and does nothing on the next run. It does not move state the tools kept elsewhere: an existing `~/.oh-my-zsh`, `~/.custom`, `~/.tmux/plugins`, `~/.nvm`, `~/.cargo` and `~/.rustup` stay where they are (delete them, or move the cargo and rustup directories to `~/.local/share/cargo` and `~/.local/share/rustup` to keep their toolchains), and npm settings in `~/.npmrc` go to `~/.config/npm/npmrc`.

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

Use `DOTFILES_CONTAINER_MINIMAL=1` to skip Oh My Zsh/plugins during image build. The images also skip the mise, AI CLI and nvim steps; run `scripts/install-mise.sh`, `scripts/install-ai-clis.sh` and `scripts/install-nvim.sh` inside a container to add them.

## Architecture

```text
.
├── packages/                # Source of truth for dependencies
│   ├── Brewfile             # Homebrew core (formulae, casks, fonts), brew bundle syntax
│   ├── apt.txt              # Debian / Raspberry Pi OS / Ubuntu
│   ├── pacman.txt           # Arch
│   └── aur.txt              # Arch (AUR)
├── scripts/
│   ├── install.sh           # main entrypoint
│   ├── install-packages.sh
│   ├── install-apt-repos.sh # Docker, Tailscale, eza and Azlux apt sources
│   ├── install-dotfiles.sh # reads config/links
│   ├── install-shell.sh     # oh-my-zsh, Powerlevel10k, zsh plugins, tpm (cloned, pulled on rerun)
│   ├── install-mise.sh      # mise, node, pnpm
│   ├── install-ai-clis.sh   # claude, codex, gemini
│   ├── install-nvim.sh      # LazyVim plugin sync
│   └── utils/               # os.sh, paths.sh, lists.sh
├── ci/
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
│   ├── links                # link table read by install-dotfiles.sh
│   ├── mise/                # .mise, config.toml (conf.d stays untracked)
│   ├── npm/.npm
│   ├── nvim/                # LazyVim: init.lua, lua/, stylua.toml, .neoconf.json
│   ├── tmux/tmux.conf
│   └── zsh/                 # .zshenv, .zshrc, .bootstrap, .exports, .aliases, .functions, .p10k.zsh
├── containers/
│   ├── Dockerfile
│   ├── Dockerfile.arch
│   └── entrypoint.sh
├── overlays/
│   ├── README.md
│   ├── os/                  # arch, debian, macos, ubuntu (zsh/.aliases)
│   └── host/                # example, mac and mini (Brewfile)
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

- `scripts/install.sh` orchestrates install sub-steps.
- `scripts/utils/os.sh` resolves `os_id` (`macos`, `arch`, `debian`, `raspbian`, `ubuntu`, or `unknown`). `debian`, `raspbian` and `ubuntu` share the apt list and `os/ubuntu.sh`.
- `scripts/install-packages.sh` installs from `packages/` per OS: `brew bundle` on the core Brewfile and then the host Brewfile on macOS, one `apt-get install` on the Debian family, one `pacman -Syu --needed` on Arch.
- `scripts/install-apt-repos.sh` adds the third-party apt sources `install_apt` needs before `apt-get update`, and skips any that is already configured.
- `scripts/install-dotfiles.sh` clears the links and files the older layout kept in `$HOME`, then applies the table in `config/links` (see [Layout](#layout)). A real file or directory in the way is backed up as `*.bak.<timestamp>`.
- `scripts/install-shell.sh` sources `config/zsh/.zshenv`, then clones Oh My Zsh, Powerlevel10k, the two zsh plugins and tpm into the XDG data directory at their default branches, unpinned. Rerunning it fast-forwards each clone (`git pull --ff-only`), so it is also the updater, and it warns and leaves a clone alone when the pull fails (offline, or a clone left at a commit by an earlier revision of the installer: delete it and rerun). Oh My Zsh's own updater stays off in `.zshrc`, so there is one updater.
- `scripts/install-mise.sh` installs mise where the package list does not (Debian family, from `https://mise.run`), then node and pnpm from `config/mise/config.toml` (its go, ruby and rust pins wait for an explicit `mise install`), plus atuin and procs on the Debian family, and runs `corepack enable`.
- `scripts/install-nvim.sh` runs `nvim --headless "+Lazy! sync" +qa` once `~/.config/nvim` is linked, and skips with a warning when nvim is missing or older than 0.11.2, the minimum LazyVim needs. The sync writes `config/nvim/lazy-lock.json`, so commit it to pin the plugin versions.
- `scripts/install-ai-clis.sh` installs claude, codex and gemini from their own installers, skipping any already on `PATH` unless `--update` is passed.
- `os/macos.sh` applies macOS `defaults`, `nvram`, and `pmset` settings (keyboard, screenshots, Dock, Finder, sleep).
- `os/ubuntu.sh` sets the locale and timezone, switches the login shell to zsh, adds the user to the docker group, and enables the docker and tailscale services.
- `os/arch.sh` does what `os/ubuntu.sh` does, plus the weekly paccache timer, the ufw defaults, and the liquidctl service.

## Overlays

Overlays provide optional OS- and host-specific shell customizations without separate repositories.

- OS overlay: `overlays/os/<id>/` where `<id>` matches `os_id`.
- Host overlay: `overlays/host/<name>/` with `DOTFILES_HOST=<name>`.
- Supported overlay files today: `zsh/.exports`, `zsh/.aliases`, `zsh/.functions`, `zsh/.bootstrap` (see `overlays/README.md`), and a `Brewfile` per host that `install-packages.sh` applies on macOS.

Example:

```text
overlays/os/ubuntu/zsh/.aliases
overlays/host/work-laptop/zsh/.exports
```

## CI and Smoke

- `ci/lint-shell.sh` runs shellcheck on installer/container shell scripts.
- `ci/devbox-smoke.sh` builds a target Dockerfile and verifies non-root login, the `~/.zshenv` and `~/.config` links, and that `ZDOTDIR` is `~/.config/zsh`.
- CI runs shellcheck in a dedicated container image and smoke tests for Ubuntu + Arch Dockerfiles.

## Notes

- Install scripts are intentionally stateful and can modify system settings/packages.
- `TOOLS.md` lists everything the repo installs and aliases, `TASKS.md` tracks open work, and `PLAN.md` lays out the next phases.

## Thanks

We can learn a lot about productivity just exploring the way people work every day. Personally, I got highly inspired by [Holman](https://github.com/holman/dotfiles), [Mathias Bynens](https://github.com/mathiasbynens/dotfiles), [Deny Dias](https://github.com/denydias/dotfiles) and by this [setup and readme](https://github.com/diessica/dotfiles).

I can't agree more with [Holman](https://github.com/holman)'s thoughts on dotfiles: [dotfiles are meant to be forked](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked).

## License

[MIT License](http://iagodahlem.mit-license.org/) © Iago Dahlem
