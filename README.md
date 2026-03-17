# .dotfiles

Personal dotfiles for **macOS** and **Linux** with a unified installer, overlays, and container support.

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
- `DOTFILES_SKIP_SHELL=1` skip Oh My Zsh and plugin install.
- `DOTFILES_SKIP_NODE_GLOBALS=1` skip global Node package install.
- `DOTFILES_SKIP_OS_DEFAULTS=1` skip OS-specific defaults/tweaks.

Global Node packages come from `config/npm/globals` and are installed with `pnpm` (or bootstrapped with `corepack` when available).

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

Use `DOTFILES_CONTAINER_MINIMAL=1` to skip Oh My Zsh/plugins during image build.

## Architecture

```text
.
├── packages/                # Source of truth for dependencies
│   ├── Brewfile             # Homebrew formulae
│   ├── Caskfile             # Homebrew casks
│   ├── Fontfile             # Homebrew font casks
│   ├── apt.txt
│   ├── pacman.txt
│   └── aur.txt
├── scripts/
│   ├── install.sh           # main entrypoint
│   ├── install-packages.sh
│   ├── install-dotfiles.sh
│   ├── install-shell.sh
│   ├── install-node-globals.sh
│   ├── devbox-smoke.sh
│   ├── lint-shell.sh
│   └── utils/os.sh
├── os/
│   ├── macos.sh
│   ├── ubuntu.sh
│   └── arch.sh
├── config/
│   ├── asdf/
│   ├── atuin/
│   ├── brew/
│   ├── cargo/
│   ├── git/
│   ├── npm/
│   ├── nvm/
│   ├── tmux/
│   └── zsh/
├── containers/
│   ├── Dockerfile
│   ├── Dockerfile.arch
│   └── entrypoint.sh
├── overlays/
│   ├── os/
│   └── host/
├── docker-compose.yml
├── .dockerignore
├── README.md
├── AGENTS.md
└── PLAN.md
```

## Runtime Flow

- `scripts/install.sh` orchestrates install sub-steps.
- `scripts/utils/os.sh` resolves `os_id` (`macos`, `ubuntu`, `debian`, `arch`, or `unknown`).
- `scripts/install-packages.sh` installs from `packages/` per OS.
- `scripts/install-dotfiles.sh` creates symlinks in `$HOME` and backs up existing files as `*.bak.<timestamp>`.
- `scripts/install-shell.sh` installs Oh My Zsh, Powerlevel10k, and Zsh plugins.
- `scripts/install-node-globals.sh` installs globals from `config/npm/globals` with `pnpm`.
- `os/*.sh` applies OS-specific tweaks/defaults.

## Overlays

Overlays provide optional OS- and host-specific shell customizations without separate repositories.

- OS overlay: `overlays/os/<os>/` where `<os>` matches `os_id`.
- Host overlay: `overlays/host/<name>/` with `DOTFILES_HOST=<name>`.
- Supported overlay files today: `zsh/.exports`, `zsh/.aliases`, `zsh/.functions`, `zsh/.bootstrap`.

Example:

```text
overlays/os/ubuntu/zsh/.aliases
overlays/host/work-laptop/zsh/.exports
```

## CI and Smoke

- `scripts/lint-shell.sh` runs shellcheck on installer/container shell scripts.
- `scripts/devbox-smoke.sh` builds a target Dockerfile and verifies non-root login and core symlinks.
- CI runs shellcheck in a dedicated container image and smoke tests for Ubuntu + Arch Dockerfiles.

## Notes

- `os/ubuntu.sh` and `os/arch.sh` are currently placeholders.
- Install scripts are intentionally stateful and can modify system settings/packages.

## Thanks

We can learn a lot about productivity just exploring the way people work every day. Personally, I got highly inspired by [Holman](https://github.com/holman/dotfiles), [Mathias Bynens](https://github.com/mathiasbynens/dotfiles), [Deny Dias](https://github.com/denydias/dotfiles) and by this [setup and readme](https://github.com/diessica/dotfiles).

I can't agree more with [Holman](https://github.com/holman)'s thoughts on dotfiles: [dotfiles are meant to be forked](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked).

## License

[MIT License](http://iagodahlem.mit-license.org/) © Iago Dahlem
