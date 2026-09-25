# TOOLS

Everything this dotfiles repo installs, configures, or aliases — grouped by OS.
Use this to compare against your system and spot what's missing.

---

## Packages by OS

### macOS (Homebrew)

**Formulae** (`packages/Brewfile`, 16):

| Package | Description |
|---|---|
| atuin | shell history search and sync |
| bat | cat clone with syntax highlighting |
| btop | system monitor |
| git-delta | syntax-highlighting git diff pager |
| duf | disk usage utility |
| eza | modern ls replacement |
| gemini-cli | terminal coding assistant |
| gh | GitHub CLI |
| htop | interactive process viewer |
| jq | JSON processor |
| mise | runtime version manager |
| mosh | mobile shell (SSH replacement) |
| ncdu | disk usage analyzer |
| neovim | text editor |
| procs | modern ps replacement |
| tmux | terminal multiplexer |

**Casks** (`packages/Caskfile`, 11):

| App | Description |
|---|---|
| 1password | password manager |
| claude-code | terminal coding assistant |
| codex | terminal coding assistant |
| ghostty | GPU-accelerated terminal emulator |
| google-chrome | web browser |
| karabiner-elements | keyboard customizer |
| raycast | launcher / productivity |
| rectangle | window management |
| slack | team messaging |
| visual-studio-code | code editor |
| workflowy | outliner / note-taking |

**Fonts** (`packages/Fontfile`, 1):

| Font | Description |
|---|---|
| font-meslo-lg-nerd-font | Meslo Nerd Font for Powerlevel10k and tmux powerline glyphs |

### Debian / Ubuntu (apt)

`packages/apt.txt` (20):

| Package | Description |
|---|---|
| bat | cat clone with syntax highlighting |
| btop | system monitor |
| ca-certificates | SSL/TLS root certs |
| curl | HTTP client |
| duf | disk usage utility |
| eza | modern ls replacement |
| git | version control |
| htop | interactive process viewer |
| jq | JSON processor |
| less | pager |
| locales | locale data |
| mosh | mobile shell (SSH replacement) |
| ncdu | disk usage analyzer |
| neovim | text editor |
| sudo | privilege escalation |
| tmux | terminal multiplexer |
| tzdata | timezone data |
| vim | text editor |
| xclip | X11 clipboard tool (tmux copy-pipe) |
| zsh | Z shell |

### Arch Linux (pacman)

`packages/pacman.txt` (35):

| Package | Description |
|---|---|
| atuin | shell history search and sync |
| base-devel | build tools (gcc, make, etc.) |
| bat | cat clone with syntax highlighting |
| btop | system monitor |
| cmatrix | matrix rain screensaver |
| ctop | container metrics |
| git-delta | syntax-highlighting git diff pager |
| docker | container runtime |
| docker-compose | multi-container orchestration |
| duf | disk usage utility |
| eza | modern ls replacement |
| fastfetch | system info display |
| gemini-cli | terminal coding assistant |
| git | version control |
| github-cli | GitHub CLI |
| jq | JSON processor |
| liquidctl | liquid cooler control |
| mise | runtime version manager |
| mkcert | local TLS certificates |
| mosh | mobile shell (SSH replacement) |
| ncdu | disk usage analyzer |
| neovim | text editor |
| openai-codex | terminal coding assistant |
| pacman-contrib | pacman cache tools; paccache.timer auto-trims the cache weekly (enabled by os/arch.sh) |
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

**AUR** (`packages/aur.txt`, 1):

| Package | Description |
|---|---|
| claude-code | terminal coding assistant |

---

## Version Managers & Runtimes

### mise (`config/mise/`)

Activated first on shell start. Runtime versions are pinned in `config/mise/`:

| Runtime | Version |
|---|---|
| golang | 1.23.4 |
| ruby | 3.1.3 |
| rust | 1.68.2 |
| nodejs | managed by mise (planned; nvm still provides node today, see `TASKS.md`) |

### nvm

Also loaded on shell start for `.nvmrc` auto-switching. Overlaps with mise for Node; dropping it is an open item in `TASKS.md`.

### cargo

Rust toolchain sourced from `$HOME/.cargo/env`.

### Homebrew (macOS + Linuxbrew)

Initialized on both macOS (`/opt/homebrew`) and Linux (`/home/linuxbrew/.linuxbrew`) when present.

---

## Node Global Packages

Installed via `pnpm` from `config/npm/globals` by `scripts/install-node-globals.sh`. The list is empty right now: the coding assistant CLIs come from the package lists above, so only packages without a formula belong here.

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

Loaded in order: mise, atuin, homebrew, cargo, nvm.

---

## tmux Plugins (TPM)

| Plugin | Purpose |
|---|---|
| tmux-plugins/tpm | plugin manager |
| tmux-plugins/tmux-sensible | sensible defaults |
| tmux-plugins/tmux-resurrect | session save/restore |
| tmux-plugins/tmux-continuum | auto session restore |
| dracula/tmux | status bar theme (a switch to tmux2k is parked in `TASKS.md`) |

---

## Git Configuration

### Tools referenced in `.gitconfig`

| Tool | Usage |
|---|---|
| nvim | core editor |
| git-delta | core pager — syntax-highlighted diffs |
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
| `df` | `df -h` | human-readable disk free |
| `du` | `du -h -d 2` | human-readable disk usage |
| `rm` | `nocorrect rm` | skip zsh correction |
| `top` | `btop` | requires btop |
| `cat` | `bat` | `batcat` where that is the binary name (Debian); only set when one of them is installed |
| `ls` | `eza --group-directories-first` | `exa` on older Debian; only set when one of them is installed, plain `ls` otherwise |
| `l` / `ll` | `eza -l --group-directories-first --git` | long list with git status |
| `la` | `eza -la --group-directories-first --git` | long list including hidden files |
| `lt` | `eza --tree --level=2 --group-directories-first` | two-level tree |
| `reload` / `r` | `. $HOME/.zshrc` | reload shell config |
| `dc` | `docker` | |
| `dcc` | `docker compose` | |

The package-manager aliases (`install`, `update`, `upgrade`, `up`, `cleanup`) live in the per-OS overlays below.

### macOS overlay — `overlays/os/macos/zsh/.aliases`

| Alias | Command |
|---|---|
| `install` | `brew install` |
| `i` | `install` |
| `cask` | `brew install --cask` |
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
| `cleanup` | `yay -Sc && yay -Yc` |

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
| `HISTIGNORE` | patterns kept out of shell history (`ls`, `cd`, `date`, `* --help`) |
| `LANG` | `en_US.UTF-8` |
| `EDITOR` | `nvim` |
| `PATH` | `/usr/local/bin`, `/usr/local/sbin`, `~/.local/bin`, and `$DOTFILES_BIN` prepended; `/snap/bin` appended when present |

---

## Tools Referenced but NOT in Package Lists

These tools appear in aliases, configs, or init scripts but are not listed in every `packages/` file they would need to be. Expect to install them manually, from a script, or via a version manager:

| Tool | Where referenced | How it's expected |
|---|---|---|
| xclip | tmux copy-pipe | in `apt.txt` only; install manually elsewhere |
| oh-my-zsh | `.zshrc` | installed by `scripts/install-shell.sh` |
| powerlevel10k | `.zshrc` theme | installed by `scripts/install-shell.sh` |
| tpm | `.tmux.conf` | not installed by any script; clone to `~/.tmux/plugins/tpm` |
| pnpm | `.zshrc`, node globals | installed via corepack or npm |
| nvm | `.bootstrap` → `.nvm` | installed manually, not in packages |
| atuin | `.bootstrap` → `.atuin` | in `Brewfile` and `pacman.txt` (missing from `apt.txt`) |
| docker | alias `dc`, omz plugin | in `pacman.txt` only (missing from `Brewfile`, `Caskfile`, `apt.txt`) |
