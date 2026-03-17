# TOOLS

Everything this dotfiles repo installs, configures, or aliases — grouped by OS.
Use this to compare against your system and spot what's missing.

---

## Packages by OS

### macOS (Homebrew)

**Formulae** (`packages/Brewfile`):

| Package | Description |
|---|---|
| bat | cat clone with syntax highlighting |
| diff-so-fancy | human-readable git diffs |
| tmux | terminal multiplexer |

**Casks** (`packages/Caskfile`):

| App | Description |
|---|---|
| 1password | password manager |
| ghostty | GPU-accelerated terminal emulator |
| google-chrome | web browser |
| karabiner-elements | keyboard customizer |
| raycast | launcher / productivity |
| rectangle | window management |
| slack | team messaging |
| visual-studio-code | code editor |
| workflowy | outliner / note-taking |

**Fonts** (`packages/Fontfile`):

Empty — no fonts installed yet. Needs Nerd Font for Powerlevel10k and tmux powerline glyphs.

### Ubuntu / Debian (apt)

`packages/apt.txt`:

| Package | Description |
|---|---|
| ca-certificates | SSL/TLS root certs |
| curl | HTTP client |
| git | version control |
| sudo | privilege escalation |
| zsh | Z shell |
| tmux | terminal multiplexer |
| vim | text editor |
| less | pager |
| locales | locale data |
| tzdata | timezone data |

### Arch Linux (pacman)

`packages/pacman.txt`:

| Package | Description |
|---|---|
| atuin | shell history search/sync |
| base-devel | build tools (gcc, make, etc.) |
| bat | cat with syntax highlighting |
| btop | system monitor |
| cmatrix | matrix rain screensaver |
| ctop | container metrics |
| diff-so-fancy | human-readable diffs |
| docker | container runtime |
| docker-compose | multi-container orchestration |
| duf | disk usage utility |
| eza | modern ls replacement |
| fastfetch | system info display |
| git | version control |
| jq | JSON processor |
| liquidctl | liquid cooler control |
| mkcert | local TLS certificates |
| mosh | mobile shell (SSH replacement) |
| ncdu | disk usage analyzer |
| neovim | text editor |
| podman | daemonless container runtime |
| podman-compose | podman orchestration |
| procs | modern ps replacement |
| python-pip | Python package manager |
| speedtest-cli | internet speed test |
| tailscale | mesh VPN |
| testdisk | data recovery |
| tmux | terminal multiplexer |
| ufw | uncomplicated firewall |
| unzip | archive extractor |
| zsh | Z shell |

**AUR** (`packages/aur.txt`):

Empty — no AUR packages configured yet.

---

## Version Managers & Runtimes

### asdf (`config/asdf/.tool-versions`)

| Plugin | Version |
|---|---|
| golang | 1.23.4 |
| ruby | 3.1.3 |
| nodejs | 23.5.0 |
| rust | 1.68.2 |

### nvm

Also loaded on shell start for `.nvmrc` auto-switching. Overlaps with asdf for Node.

### cargo

Rust toolchain sourced from `$HOME/.cargo/env`.

### Homebrew (macOS + Linuxbrew)

Initialized on both macOS (`/opt/homebrew`) and Linux (`/home/linuxbrew/.linuxbrew`) when present.

---

## Node Global Packages

Installed via `pnpm` from `config/npm/globals`:

| Package | Description |
|---|---|
| codex | OpenAI CLI agent |

---

## Shell (zsh + Oh My Zsh)

### Oh My Zsh plugins

Loaded in `.zshrc`:

| Plugin | Purpose |
|---|---|
| docker | docker completions |
| docker-compose | compose completions |
| git | git aliases and completions |
| gitfast | faster git completions |
| npm | npm completions |
| tmux | tmux helpers |
| z | frecency-based directory jumping |
| zsh-autosuggestions | fish-like inline suggestions |
| zsh-syntax-highlighting | command syntax coloring |
| web-search | `google <query>` from terminal |

### Theme

Powerlevel10k (`powerlevel10k/powerlevel10k`) with instant prompt and custom `.p10k.zsh`.

### Tool initialization (via `.bootstrap`)

Loaded in order: asdf, atuin, homebrew, cargo, nvm.

---

## tmux Plugins (TPM)

| Plugin | Purpose |
|---|---|
| tmux-plugins/tpm | plugin manager |
| tmux-plugins/tmux-sensible | sensible defaults |
| tmux-plugins/tmux-resurrect | session save/restore |
| tmux-plugins/tmux-continuum | auto session restore |
| dracula/tmux | status bar theme (planned: replace with tmux2k) |

---

## Git Configuration

### Tools referenced in `.gitconfig`

| Tool | Usage |
|---|---|
| nvim | core editor |
| diff-so-fancy | core pager (via `diff-so-fancy \| less`) |
| ssh (ed25519) | GPG signing format |

### Git aliases (`config/git/.gitconfig [alias]`)

| Alias | Command |
|---|---|
| `ad` | `add` |
| `aa` | `add --all` |
| `ap` | `add -p` |
| `br` | `branch` |
| `bra` | `branch -a` |
| `brd` | `branch -d` |
| `brD` | `branch -D` |
| `brl` | `branch -l` |
| `brv` | `branch -v` |
| `co` | `checkout` |
| `cob` | `checkout -b` |
| `com` | `checkout master` |
| `cp` | `cherry-pick -x` |
| `cl` | `clone` |
| `ci` | `commit` |
| `cim` | `commit -m` |
| `cia` | `commit --amend` |
| `ciam` | `commit -am` |
| `amend` | `commit --amend --no-edit` |
| `df` | `diff` |
| `dfs` | `diff --staged` |
| `dfc` | `diff --cached` |
| `last` | `diff HEAD^` |
| `ft` | `fetch` |
| `ftp` | `fetch --prune` |
| `bam` | delete merged branches (except master/develop/main) |
| `aliases` | list all git aliases |
| `branchs` | `branch -v` |
| `configs` | `config --list` |
| `remotes` | `remote -v` |
| `tags` | `tag -l` |
| `l` | `log --oneline --date=short` |
| `lg` | `log --oneline --graph` (pretty) |
| `mg` | `merge` |
| `mgm` | `merge master` |
| `mgd` | `merge develop` |
| `pl` | `pull` |
| `plp` | `pull --prune` |
| `ps` | `push` |
| `psu` | `push -u` |
| `psf` | `push -f` |
| `psuo` | `push -u origin` |
| `psuom` | `push -u origin master` |
| `undopush` | `push -f origin HEAD^:master` |
| `rt` | `reset` |
| `rts` | `reset --soft HEAD~1` |
| `rth` | `reset --hard HEAD~1` |
| `sh` | `stash` |
| `sha` | `stash apply` |
| `shd` | `stash drop` |
| `shl` | `stash list` |
| `shp` | `stash pop` |
| `shs` | `stash show` |
| `st` | `status` |
| `ss` | `status -s` |

---

## Shell Aliases

### Shared (all OS) — `config/zsh/.aliases`

| Alias | Command | Notes |
|---|---|---|
| `dots` | `cd $DOTFILES` | jump to dotfiles dir |
| `install` | `brew install` | overridden per OS |
| `cask` | `brew cask install` | macOS only |
| `update` | `brew update` | overridden per OS |
| `upgrade` | `brew upgrade` | overridden per OS |
| `up` | `update && upgrade` | overridden per OS |
| `cleanup` | `brew cleanup` | overridden per OS |
| `dev` | `cd $CODE` | jump to code dir |
| `desktop` | `cd $DESKTOP` | |
| `downloads` | `cd $DOWNLOADS` | |
| `dlist` | `dirs -v \| head -10` | directory stack |
| `dv` | `dev` | shortcut |
| `dt` | `desktop` | shortcut |
| `dl` | `downloads` | shortcut |
| `df` | `df -h` | human-readable disk free |
| `du` | `du -h -d 2` | human-readable disk usage |
| `rm` | `nocorrect rm` | skip zsh correction |
| `top` | `htop` | requires htop |
| `reload` / `r` | `. $HOME/.zshrc` | reload shell config |
| `dc` | `docker` | |
| `dcc` | `docker compose` | |
| `bi` | `bundle install` | Ruby bundler |
| `bx` | `bundle exec` | Ruby bundler |

### macOS overlay — `overlays/os/macos/zsh/.aliases`

| Alias | Command |
|---|---|
| `install` | `brew install` |
| `i` | `install` |
| `cask` | `brew cask install` |
| `update` | `brew update` |
| `upgrade` | `brew upgrade` |
| `up` | `update && upgrade` |
| `cleanup` | `brew cleanup` |

### Ubuntu overlay — `overlays/os/ubuntu/zsh/.aliases`

| Alias | Command |
|---|---|
| `install` | `sudo apt install -y` |
| `update` | `sudo apt update -y` |
| `upgrade` | `sudo apt upgrade` |
| `autoclean` | `sudo apt auto-clean` |
| `autoremove` | `sudo apt auto-remove` |
| `i` | `install` |
| `up` | `update && upgrade` |
| `cleanup` | `autoclean && autoremove` |

### Arch overlay — `overlays/os/arch/zsh/.aliases`

| Alias | Command |
|---|---|
| `install` | `sudo pacman -S` |
| `update` | `sudo pacman -Syy` |
| `upgrade` | `sudo pacman -Syu` |
| `i` | `install` |
| `up` | `update && upgrade` |
| `cleanup` | `sudo pacman -Scc` |

---

## Shell Functions

### Shared — `config/zsh/.functions`

| Function | Purpose |
|---|---|
| `mkd <dir>` | mkdir + cd in one step |
| `e [path]` | open `$EDITOR` (current dir if no args) |
| `git-clean` | fetch and delete local branches whose remote is gone |

---

## Environment & Exports

From `config/zsh/.exports`:

| Variable | Value / Purpose |
|---|---|
| `LANG` | `en_US.UTF-8` |
| `EDITOR` | `code` (local) / `vim` (SSH) |
| `NODE_EXTRA_CA_CERTS` | auto-set from `mkcert -CAROOT` when mkcert is available |

---

## Tools Referenced but NOT in Package Lists

These tools appear in aliases, configs, or init scripts but are **not** listed in any `packages/` file — they are expected to be installed manually or via version managers:

| Tool | Where referenced | How it's expected |
|---|---|---|
| htop | alias `top=htop` | manual install / missing from package lists |
| xclip | tmux copy-pipe | manual install / missing from package lists |
| oh-my-zsh | `.zshrc` | installed by `scripts/install-shell.sh` |
| powerlevel10k | `.zshrc` theme | installed by `scripts/install-shell.sh` |
| pnpm | `.zshrc`, node globals | installed via corepack or npm |
| nvm | `.bootstrap` → `.nvm` | installed manually / not in packages |
| asdf | `.bootstrap` → `.asdf` | installed manually / not in packages |
| atuin | `.bootstrap` → `.atuin` | in pacman.txt only (missing from Brewfile/apt) |
| mkcert | `.exports` | in pacman.txt only (missing from Brewfile/apt) |
| neovim | `.gitconfig` core.editor | in pacman.txt only (missing from Brewfile/apt) |
| docker | alias `dc`, omz plugin | in pacman.txt only (missing from Brewfile/apt) |
| jq | — | in pacman.txt only (missing from Brewfile/apt) |
| eza | — | in pacman.txt only (missing from Brewfile/apt) |
