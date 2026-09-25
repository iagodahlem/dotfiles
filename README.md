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
- `DOTFILES_SKIP_SHELL=1` skip Oh My Zsh and plugin install.
- `DOTFILES_SKIP_MISE=1` skip mise, node and pnpm.
- `DOTFILES_SKIP_AI_CLIS=1` skip the AI CLI installs (claude, codex, gemini).
- `DOTFILES_SKIP_OS_DEFAULTS=1` skip OS-specific defaults/tweaks.

On macOS the packages are one core `packages/Brewfile` applied with `brew bundle`, plus the Brewfile of the host named by `DOTFILES_HOST` (default `hostname -s`) in `overlays/host/<name>/`. For example, `DOTFILES_HOST=mac ./scripts/install.sh` also applies `overlays/host/mac/Brewfile`. Debian, Raspberry Pi OS and Ubuntu use `packages/apt.txt`, after `scripts/install-apt-repos.sh` adds the Docker, Tailscale, eza and Azlux repositories. Arch uses `packages/pacman.txt` and `packages/aur.txt`.

`scripts/install-mise.sh` sets up mise, node and pnpm from `config/mise/config.toml`, and `scripts/install-ai-clis.sh` installs the AI CLIs from their own installers (`--update` refreshes ones already installed). If either step fails the installer warns and carries on.

Setting up a new machine? See [`docs/new-mac.md`](docs/new-mac.md) for the exact sequence, the machine profile, and the per-machine git identity step.

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

Use `DOTFILES_CONTAINER_MINIMAL=1` to skip Oh My Zsh/plugins during image build. The images also skip the mise and AI CLI steps; run `scripts/install-mise.sh` and `scripts/install-ai-clis.sh` inside a container to add them.

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
│   ├── install-dotfiles.sh
│   ├── install-shell.sh
│   ├── install-mise.sh      # mise, node, pnpm
│   ├── install-ai-clis.sh   # claude, codex, gemini
│   ├── devbox-smoke.sh
│   ├── lint-shell.sh
│   └── utils/               # os.sh, paths.sh
├── os/
│   ├── macos.sh
│   ├── ubuntu.sh            # also used for Debian
│   └── arch.sh
├── config/
│   ├── atuin/.atuin
│   ├── brew/.homebrew
│   ├── cargo/.cargo
│   ├── git/                 # .gitconfig, .gitconfig.override.example, .gitignore_global, .gitmessage
│   ├── mise/                # .mise, config.toml, .tool-versions
│   ├── npm/.npm
│   ├── nvm/.nvm
│   ├── tmux/.tmux.conf
│   └── zsh/                 # .zshrc, .bootstrap, .exports, .aliases, .functions, .p10k.zsh
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
- `scripts/install-dotfiles.sh` creates symlinks in `$HOME` and backs up existing files as `*.bak.<timestamp>`. `config/mise/config.toml` links to `~/.config/mise/config.toml` (node and pnpm) and `config/mise/.tool-versions` to `~/.tool-versions` (go, ruby, rust).
- `scripts/install-shell.sh` installs Oh My Zsh, Powerlevel10k, and Zsh plugins.
- `scripts/install-mise.sh` installs mise where the package list does not (Debian family, from `https://mise.run`), then node and pnpm from `config/mise/config.toml`, plus atuin and procs on the Debian family, and runs `corepack enable`.
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

- `scripts/lint-shell.sh` runs shellcheck on installer/container shell scripts.
- `scripts/devbox-smoke.sh` builds a target Dockerfile and verifies non-root login and core symlinks.
- CI runs shellcheck in a dedicated container image and smoke tests for Ubuntu + Arch Dockerfiles.

## Notes

- Install scripts are intentionally stateful and can modify system settings/packages.
- `TOOLS.md` lists everything the repo installs and aliases, `TASKS.md` tracks open work, and `PLAN.md` lays out the next phases.

## Thanks

We can learn a lot about productivity just exploring the way people work every day. Personally, I got highly inspired by [Holman](https://github.com/holman/dotfiles), [Mathias Bynens](https://github.com/mathiasbynens/dotfiles), [Deny Dias](https://github.com/denydias/dotfiles) and by this [setup and readme](https://github.com/diessica/dotfiles).

I can't agree more with [Holman](https://github.com/holman)'s thoughts on dotfiles: [dotfiles are meant to be forked](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked).

## License

[MIT License](http://iagodahlem.mit-license.org/) © Iago Dahlem
