# .dotfiles

:computer: Personal dotfiles for **macOS** and **Linux** with a unified installer and container support.

[![devbox-smoke](https://github.com/iagodahlem/dotfiles/actions/workflows/devbox-smoke.yml/badge.svg)](https://github.com/iagodahlem/dotfiles/actions/workflows/devbox-smoke.yml)

## Installation

1. Check for software updates (macOS only).

```sh
sudo softwareupdate -i -r
```

2. Clone the repo.

```sh
git clone git@github.com:iagodahlem/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

3. Install packages + dotfiles.

```sh
./scripts/install.sh
```

## Architecture

```text
.
├── packages/                # Source of truth for deps
│   ├── Brewfile
│   ├── Caskfile
│   ├── Fontfile
│   ├── apt.txt
│   ├── pacman.txt
│   └── aur.txt
├── scripts/                 # All logic lives here
│   ├── install.sh           # entrypoint: detects OS + runs tasks
│   ├── install-packages.sh  # installs packages from packages/
│   ├── install-dotfiles.sh  # symlinks configs
│   ├── install-shell.sh     # oh-my-zsh, plugins, p10k
│   └── install-container.sh # container-safe subset
├── os/                      # OS-specific tweaks
│   ├── macos.sh
│   ├── ubuntu.sh
│   └── arch.sh
├── config/                  # App configs
│   ├── zsh/
│   ├── git/
│   ├── tmux/
│   ├── vim/
│   └── vscode/
├── containers/
│   ├── Dockerfile
│   ├── Dockerfile.arch
│   ├── entrypoint.sh
│   └── docker-compose.arch.yml
├── docker-compose.yml
├── README.md
└── AGENTS.md
```

## Principles

- `packages/` is the single source of truth for dependencies.
- `scripts/install.sh` is the only public entrypoint; everything else is a sub-step.
- `os/` holds OS-only tweaks and defaults.
- `config/` is purely static configs; scripts should never “know” their contents.
- Containers use the same `scripts/` entrypoint (no duplicated logic).

## Container (Minimal)

Build a minimal devbox container that runs these dotfiles:

```sh
docker build -f containers/Dockerfile -t dotfiles-devbox .
docker run --rm -it dotfiles-devbox
```

To skip Oh My Zsh + plugins (faster build):

```sh
docker build --build-arg DOTFILES_CONTAINER_MINIMAL=1 -f containers/Dockerfile -t dotfiles-devbox .
```

## Container (Compose)

```sh
docker compose build
docker compose run --rm devbox
```

To skip Oh My Zsh + plugins (faster build):

```sh
DOTFILES_CONTAINER_MINIMAL=1 docker compose build
```

## Container (Arch)

```sh
docker compose -f docker-compose.yml -f containers/docker-compose.arch.yml build
docker compose -f docker-compose.yml -f containers/docker-compose.arch.yml run --rm devbox
```

## Thanks

We can learn a lot about productivity just exploring the way people work every day. Personally, I got highly inspired by [Holman](https://github.com/holman/dotfiles), [Mathias Bynens](https://github.com/mathiasbynens/dotfiles), [Deny Dias](https://github.com/denydias/dotfiles) and by this [setup and readme](https://github.com/diessica/dotfiles).

I can't agree more with [Holman](https://github.com/holman)'s thoughts on dotfiles: [dotfiles are meant to be forked](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked).

## License

[MIT License](http://iagodahlem.mit-license.org/) © Iago Dahlem
