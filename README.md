# .dotfiles

:computer: My personal dotfiles and tweaks for **macOS**.

[![devbox-smoke](https://github.com/iagodahlem/dotfiles/actions/workflows/devbox-smoke.yml/badge.svg)](https://github.com/iagodahlem/dotfiles/actions/workflows/devbox-smoke.yml)

## Installation

I'm using [Homebrew](https://brew.sh/) to install Mac applications, command-line tools and fonts.

**1.** Check for software updates.

```sh
$ sudo softwareupdate -i -r
```

**2.** Get this project somehow and go to its directory.

```sh
git clone git@github.com:iagodahlem/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

**3.** Install Mac applications (see [caskfile](brew/caskfile)) and fonts (see [fontfile](brew/fontfile)).

```sh
$ sh ./install-apps
```

**4.** Install dotfiles (see [Brewfile](packages/Brewfile)).

```sh
$ sh ./install-dotfiles
```

Preferred entrypoint (same behavior):

```sh
./scripts/install.sh
```

**5.** Tell [npm](https://www.npmjs.com/) who you are.

```sh
$ npm set init.author.name "{Your name}"
$ npm set init.author.email "{Your email}"
$ npm set init.author.url "{Your URL}"
$ npm adduser
```

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
