# TOOLS

Everything this dotfiles repo installs, configures, or aliases — grouped by OS.
Use this to compare against your system and spot what's missing.

---

## Packages by OS

### macOS (Homebrew)

`packages/Brewfile` (46 entries) is applied with `brew bundle` on every Mac. `brew bundle` skips an app that already exists outside Homebrew and keeps going. The Brewfile of the host named by `DOTFILES_HOST` (default `hostname -s`) in `overlays/host/<name>/` is applied on top of it.

**Formulae** (25):

| Package | Description |
|---|---|
| atuin | shell history search and sync |
| bat | cat clone with syntax highlighting |
| btop | system monitor |
| ctop | container metrics |
| duf | disk usage utility |
| eza | modern ls replacement |
| fastfetch | system info display |
| fd | find replacement |
| fzf | fuzzy finder |
| gh | GitHub CLI |
| git | version control |
| git-delta | syntax-highlighting git diff pager |
| jq | JSON processor |
| less | pager |
| mise | runtime version manager |
| mole | Mac cleanup and disk analyzer |
| mosh | mobile shell (SSH replacement) |
| ncdu | disk usage analyzer |
| neovim | text editor |
| procs | modern ps replacement |
| ripgrep | grep replacement |
| rtk | compresses noisy command output |
| speedtest-cli | internet speed test |
| tmux | terminal multiplexer |
| zsh | Z shell |

**Casks** (19):

| App | Description |
|---|---|
| 1password | password manager |
| 1password-cli | 1Password command line client |
| codexbar | menu bar usage monitor |
| ghostty | GPU-accelerated terminal emulator |
| google-chrome | web browser |
| karabiner-elements | keyboard customizer |
| keepingyouawake | keeps the Mac from sleeping |
| obsidian | notes |
| orbstack | container runtime and Linux VMs (provides the docker CLI) |
| raycast | launcher / productivity |
| rectangle | window management |
| slack | team messaging |
| stats | menu bar system monitor |
| tailscale-app | mesh VPN |
| telegram | messaging |
| the-unarchiver | archive extractor |
| thebrowsercompany-dia | web browser |
| transmission | BitTorrent client |
| visual-studio-code | code editor |

**Fonts** (2, casks in the same Brewfile):

| Font | Description |
|---|---|
| font-fira-code-nerd-font | Fira Code Nerd Font |
| font-meslo-lg-nerd-font | Meslo Nerd Font for Powerlevel10k and tmux powerline glyphs |

**Host overlays** (`overlays/host/<name>/Brewfile`):

`mac`, the personal Mac (21 entries, everything on top of the core):

| Entry | Kind | Description |
|---|---|---|
| cmatrix | formula | matrix rain screensaver |
| nmap | formula | network scanner |
| putty | formula | SSH and serial client |
| backdrop | cask | wallpapers |
| blender | cask | 3D suite |
| google-drive | cask | cloud storage |
| granola | cask | meeting notes |
| jettison | cask | ejects external drives on sleep |
| notion | cask | notes and docs |
| notion-calendar | cask | calendar |
| qmk-toolbox | cask | keyboard firmware flasher |
| spotify | cask | music |
| steam | cask | games |
| workflowy | cask | outliner / note-taking |
| bartender | cask | menu bar organizer, installed outside Homebrew today |
| bettertouchtool | cask | input customizer, installed outside Homebrew today |
| cleanshot | cask | screenshots and screen recording, installed outside Homebrew today |
| logi-options+ | cask | Logitech mouse and keyboard settings, installed outside Homebrew today |
| readdle-spark | cask | mail client, installed outside Homebrew today |
| whatsapp | cask | messaging, installed outside Homebrew today |
| zoom | cask | video calls, installed outside Homebrew today |

`mini`, a work machine (0 entries): empty on purpose, the core Brewfile is all it gets.

### Debian / Raspberry Pi OS / Ubuntu (apt)

`packages/apt.txt` (33) is installed in one `apt-get install --no-install-recommends` after `scripts/install-apt-repos.sh` adds the third-party sources below. A package with no candidate on the running release is skipped with a warning (`fastfetch` needs Debian 13 or newer, for instance).

| Package | Description |
|---|---|
| bat | cat clone with syntax highlighting, installs as `batcat` |
| bind9-dnsutils | dig and nslookup |
| btop | system monitor |
| ca-certificates | SSL/TLS root certs |
| containerd.io | container runtime (Docker repository) |
| curl | HTTP client |
| docker-buildx-plugin | docker buildx (Docker repository) |
| docker-ce | Docker engine (Docker repository) |
| docker-ce-cli | Docker CLI (Docker repository) |
| docker-compose-plugin | docker compose (Docker repository) |
| docker-ctop | container metrics (Azlux repository) |
| duf | disk usage utility |
| eza | modern ls replacement (eza repository) |
| fastfetch | system info display |
| fd-find | find replacement, installs as `fdfind` |
| fzf | fuzzy finder |
| gh | GitHub CLI |
| git | version control |
| git-delta | syntax-highlighting git diff pager |
| jq | JSON processor |
| less | pager |
| locales | locale data |
| mosh | mobile shell (SSH replacement) |
| ncdu | disk usage analyzer |
| neovim | text editor |
| ripgrep | grep replacement |
| speedtest-cli | internet speed test |
| sudo | privilege escalation |
| tailscale | mesh VPN (Tailscale repository) |
| tmux | terminal multiplexer |
| tzdata | timezone data |
| xclip | X11 clipboard tool (tmux copy-pipe) |
| zsh | Z shell |

`mise` comes from its installer and `atuin` and `procs` through mise, see [Version Managers & Runtimes](#version-managers--runtimes).

**Third-party apt repositories** (added by `scripts/install-apt-repos.sh`, each skipped when its sources file already exists):

| Repository | Provides | Sources file | Key |
|---|---|---|---|
| `download.docker.com/linux/debian` (`ubuntu` on Ubuntu) | docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin | `docker.sources` | `/etc/apt/keyrings/docker.asc` |
| `pkgs.tailscale.com/stable/debian` (`ubuntu` on Ubuntu) | tailscale | `tailscale.sources` | `/usr/share/keyrings/tailscale-archive-keyring.gpg` |
| `deb.gierens.de` | eza | `gierens.sources` | `/etc/apt/keyrings/gierens.asc` |
| `packages.azlux.fr/debian` | docker-ctop | `azlux.sources` | `/usr/share/keyrings/azlux-archive-keyring.gpg` |

### Arch Linux (pacman)

`packages/pacman.txt` (38) is installed in one `pacman -Syu --needed` transaction.

| Package | Description |
|---|---|
| atuin | shell history search and sync |
| base-devel | build tools (gcc, make, etc.) |
| bat | cat clone with syntax highlighting |
| bind | dig and nslookup |
| btop | system monitor |
| ctop | container metrics |
| docker | container runtime |
| docker-buildx | docker buildx |
| docker-compose | multi-container orchestration |
| duf | disk usage utility |
| eza | modern ls replacement |
| fastfetch | system info display |
| fd | find replacement |
| fzf | fuzzy finder |
| git | version control |
| git-delta | syntax-highlighting git diff pager |
| github-cli | GitHub CLI |
| jq | JSON processor |
| less | pager |
| liquidctl | liquid cooler control |
| mise | runtime version manager |
| mosh | mobile shell (SSH replacement) |
| ncdu | disk usage analyzer |
| neovim | text editor |
| pacman-contrib | pacman cache tools; paccache.timer auto-trims the cache weekly (enabled by os/arch.sh) |
| procs | modern ps replacement |
| python-pip | Python package manager |
| ripgrep | grep replacement |
| shellcheck | shell script linter |
| speedtest-cli | internet speed test |
| tailscale | mesh VPN |
| tmux | terminal multiplexer |
| ttf-cascadia-code-nerd | Cascadia Code Nerd Font |
| ttf-firacode-nerd | Fira Code Nerd Font |
| ttf-meslo-nerd | Meslo Nerd Font for Powerlevel10k and tmux powerline glyphs |
| ufw | uncomplicated firewall |
| unzip | archive extractor |
| zsh | Z shell |

**AUR** (`packages/aur.txt`, 1), installed through yay when `AUR_USER` is set; yay bootstraps itself in `install_aur`:

| Package | Description |
|---|---|
| google-cloud-cli | gcloud CLI |

---

## Version Managers & Runtimes

### mise (`config/mise/`)

Activated first on shell start. `mise` itself comes from `packages/Brewfile` on macOS, `packages/pacman.txt` on Arch, and `https://mise.run` on the Debian family. `scripts/install-mise.sh` installs the tools below, then runs `corepack enable`.

| Tool | Version | Where it is declared |
|---|---|---|
| node | lts | `config/mise/config.toml` |
| pnpm | latest | `config/mise/config.toml` |
| golang | 1.23.4 | `config/mise/.tool-versions` (not installed by the installer) |
| ruby | 3.1.3 | `config/mise/.tool-versions` (not installed by the installer) |
| rust | 1.68.2 | `config/mise/.tool-versions` (not installed by the installer) |
| atuin | latest | Debian family only, `~/.config/mise/conf.d/apt-gaps.toml` written by `scripts/install-mise.sh` |
| github:dalance/procs | latest | Debian family only, same fragment (`procs`) |

### nvm

Also loaded on shell start for `.nvmrc` auto-switching. Overlaps with mise for Node; the shell hook goes in the next pass, see `TASKS.md`.

### cargo

Rust toolchain sourced from `$HOME/.cargo/env`.

### Homebrew (macOS + Linuxbrew)

Initialized on both macOS (`/opt/homebrew`) and Linux (`/home/linuxbrew/.linuxbrew`) when present.

---

## AI CLIs

Installed by `scripts/install-ai-clis.sh` on every OS from the vendors' own installers, not from the package lists. One that is already on `PATH` is skipped unless `--update` is given.

| CLI | Installed with |
|---|---|
| claude | `curl -fsSL https://claude.ai/install.sh \| bash` |
| codex | `curl -fsSL https://chatgpt.com/codex/install.sh \| sh` |
| gemini | `npm install -g @google/gemini-cli`, run with the node mise installs |

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
| `df` | `duf` | disk free; `df -h` when `duf` is not installed |
| `du` | `ncdu` | disk usage browser; `du -h -d 2` when `ncdu` is not installed |
| `dus` | `command du -h -d 2` | plain two-level disk usage, always the real `du` |
| `ps` | `procs` | only set when `procs` is installed, plain `ps` otherwise |
| `rm` | `nocorrect rm` | skip zsh correction |
| `top` | `btop` | requires btop |
| `cat` | `bat` | `batcat` where that is the binary name (Debian); only set when one of them is installed |
| `fd` | `fdfind` | only set where `fd` is missing and `fdfind` is the binary name (Debian) |
| `ls` | `eza --group-directories-first` | `exa` on older Debian; only set when one of them is installed, plain `ls` otherwise; oh-my-zsh's `ll`, `la` and `l` go through it |
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

### Ubuntu and Debian overlays — `overlays/os/ubuntu/zsh/.aliases`, `overlays/os/debian/zsh/.aliases` (same content)

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
| xclip | tmux copy-pipe | in `apt.txt` only; the clipboard rework is an open item in `TASKS.md` |
| mise | `.bootstrap` → `.mise` | in `Brewfile` and `pacman.txt`; on the Debian family `scripts/install-mise.sh` installs it from `https://mise.run` |
| atuin | `.bootstrap` → `.atuin` | in `Brewfile` and `pacman.txt`; on the Debian family through mise (`scripts/install-mise.sh`) |
| procs | alias `ps` | in `Brewfile` and `pacman.txt`; on the Debian family through mise (`scripts/install-mise.sh`) |
| node, pnpm | `.zshrc`, npm-based CLIs | installed through mise by `scripts/install-mise.sh` (nvm still loads in the shell until the next pass) |
| claude, codex, gemini | run as `claude`, `codex`, `gemini` | `scripts/install-ai-clis.sh`, not in any package list |
| oh-my-zsh | `.zshrc` | installed by `scripts/install-shell.sh` |
| powerlevel10k | `.zshrc` theme | installed by `scripts/install-shell.sh` |
| tpm | `.tmux.conf` | not installed by any script; clone to `~/.tmux/plugins/tpm` |
| nvm | `.bootstrap` → `.nvm` | installed manually, not in packages |
