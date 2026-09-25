# TOOLS

Everything this dotfiles repo installs, configures, or aliases — grouped by OS.
Use this to compare against your system and spot what's missing.

---

## Where things live

`~/.zshenv` is the only dotfile in `$HOME`. It sets the XDG variables and the redirects below, and zsh then reads the rest from `ZDOTDIR`. The tracked files are linked in by the table in `config/links`, see the README. A row with no tracked source is state the tool writes, kept out of the repo on purpose.

| Tool | Tracked source | Live path | XDG variable |
|---|---|---|---|
| zsh environment | `config/zsh/.zshenv` | `~/.zshenv` (file link) | sets `XDG_*` and `ZDOTDIR` |
| zsh config | `config/zsh/` | `~/.config/zsh` (directory link) | `ZDOTDIR` |
| zsh machine-private lines | none, untracked and gitignored (`local.zsh.example` is the template) | `config/zsh/local.zsh` in the checkout, reached as `~/.config/zsh/local.zsh` | none, `.bootstrap` sources it last |
| zsh history | none | `~/.local/state/zsh/history` | `HISTFILE`, `XDG_STATE_HOME` |
| zsh completion dump | none | `~/.cache/zsh/zcompdump-<version>` | `ZSH_COMPDUMP`, `XDG_CACHE_HOME` |
| macOS Terminal session files | none | not written, `SHELL_SESSIONS_DISABLE=1` switches off the save and restore that would put them in `ZDOTDIR` | `SHELL_SESSIONS_DISABLE` |
| oh-my-zsh | none, cloned by `scripts/install-shell.sh` | `~/.local/share/oh-my-zsh` | `ZSH` |
| Powerlevel10k and zsh plugins | none, cloned by `scripts/install-shell.sh` | `~/.local/share/oh-my-zsh-custom` | `ZSH_CUSTOM` |
| z (oh-my-zsh plugin) | none | `~/.local/share/z/data`, and `data.lock` beside it | `ZSHZ_DATA` |
| tmux | `config/tmux/` | `~/.config/tmux` (directory link) | `XDG_CONFIG_HOME` (tmux 3.2 and newer) |
| tpm and tmux plugins | none, tpm cloned by `scripts/install-shell.sh` | `~/.local/share/tmux/plugins` | `TMUX_PLUGIN_MANAGER_PATH` |
| git | `config/git/` | `~/.config/git` (directory link) | `XDG_CONFIG_HOME` |
| git identity and host settings | none, untracked and gitignored (`local.example` is the template; `host` is reserved for the host overlays) | `config/git/local`, `config/git/host` in the checkout, reached as `~/.config/git/local` and `~/.config/git/host` | none, included by path from `config` |
| ghostty | `config/ghostty/` | `~/.config/ghostty` (directory link) | `XDG_CONFIG_HOME` |
| neovim config | `config/nvim/` | `~/.config/nvim` (directory link) | `XDG_CONFIG_HOME` |
| neovim plugins | none, synced by `scripts/install-nvim.sh` | `~/.local/share/nvim` | `XDG_DATA_HOME` |
| mise | `config/mise/` | `~/.config/mise` (directory link) | `XDG_CONFIG_HOME` |
| mise Debian fragment | none, untracked and gitignored, written by `scripts/install-mise.sh` on the Debian family | `config/mise/conf.d/` in the checkout, reached as `~/.config/mise/conf.d/` | none, mise loads `conf.d/*.toml` from its config directory |
| cargo | none | `~/.local/share/cargo` | `CARGO_HOME` |
| rustup | none | `~/.local/share/rustup` | `RUSTUP_HOME` |
| npm user config | none, untracked | `~/.config/npm/npmrc` | `NPM_CONFIG_USERCONFIG` |
| npm cache | none | `~/.cache/npm` | `NPM_CONFIG_CACHE` |
| claude | none | `~/.config/claude` (settings, history, plugins and `.claude.json`) | `CLAUDE_CONFIG_DIR` |
| codex | none | `~/.local/share/codex` (`config.toml`, auth, sessions and the standalone install's `packages/`; the CLI exits when the directory is missing, so `.zshrc` creates it) | `CODEX_HOME` |
| gemini | none | `~/.local/share/gemini/.gemini` (settings and history) | `GEMINI_CLI_HOME` |

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

`mac`, the personal Mac (20 entries, everything on top of the core):

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
| pacman-contrib | pacman cache tools (`paccache`); the weekly timer is host-level and lives in the machines repo |
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

## OS defaults

`scripts/install.sh` runs the OS defaults script as its last step (`--only os-defaults` runs just that, `--dry-run` prints the commands).

### macOS (`os/macos.sh`)

Written with `defaults write`, one line each, with a comment in the script. Key repeat applies after the next login.

| Domain | Key | Value | Effect |
|---|---|---|---|
| `NSGlobalDomain` | `NSDocumentSaveNewDocumentsToCloud` | `false` | save to disk, not to iCloud, by default |
| `NSGlobalDomain` | `AppleKeyboardUIMode` | `3` | full keyboard access, Tab reaches every control in dialogs |
| `NSGlobalDomain` | `KeyRepeat` | `2` | fast key repeat |
| `NSGlobalDomain` | `InitialKeyRepeat` | `15` | short wait before key repeat starts |
| `NSGlobalDomain` | `NSAutomaticQuoteSubstitutionEnabled` | `false` | no smart quotes |
| `NSGlobalDomain` | `NSAutomaticDashSubstitutionEnabled` | `false` | no smart dashes |
| `NSGlobalDomain` | `NSAutomaticSpellingCorrectionEnabled` | `false` | no autocorrect |
| `NSGlobalDomain` | `AppleShowAllExtensions` | `true` | show all filename extensions |
| `com.google.Chrome` | `AppleEnableSwipeNavigateWithScrolls` | `false` | no back and forward navigation on a horizontal scroll |
| `com.apple.screencapture` | `location` | `~/Documents/Screenshots` | screenshots go there (the script creates the folder) |
| `com.apple.screencapture` | `type` | `png` | screenshots as PNG |
| `com.apple.dock` | `orientation` | `right` | Dock on the right |
| `com.apple.dock` | `minimize-to-application` | `true` | windows minimize into their application's icon |
| `com.apple.finder` | `QuitMenuItem` | `true` | Cmd+Q quits Finder |
| `com.apple.finder` | `ShowExternalHardDrivesOnDesktop`, `ShowHardDrivesOnDesktop`, `ShowMountedServersOnDesktop`, `ShowRemovableMediaOnDesktop` | `false` | no drive, server or removable media icons on the desktop |
| `com.apple.finder` | `AppleShowAllFiles` | `true` | show hidden files |

Two more lines are not `defaults write`: `sudo systemsetup -setrestartfreeze on` restarts the Mac automatically if it freezes, and is the only line that needs sudo (a failure there only warns); `killall Finder`, `Dock` and `SystemUIServer` at the end make the settings above show up now.

### Linux (`os/arch.sh`, `os/ubuntu.sh`)

Both do the same two things, each guarded so a failure only warns, and `os/ubuntu.sh` also serves Debian and Raspberry Pi OS.

| Action | Condition |
|---|---|
| `chsh -s $(command -v zsh)` | zsh is installed and is not the login shell already |
| `sudo usermod -aG docker $USER` | the `docker` group exists and the user is not in it |

Locale, timezone, service enables, the firewall and drivers are host-level settings and live in the machines repo, not in the dotfiles.

---

## Version Managers & Runtimes

### mise (`config/mise/`)

Activated first on shell start. `mise` itself comes from `packages/Brewfile` on macOS, `packages/pacman.txt` on Arch, and `https://mise.run` on the Debian family. `scripts/install-mise.sh` installs the tools below, then runs `corepack enable`.

| Tool | Version | Where it is declared |
|---|---|---|
| node | lts | `config/mise/config.toml` |
| pnpm | latest | `config/mise/config.toml` |
| go | 1.23.4 | `config/mise/config.toml` (not installed by the installer) |
| ruby | 3.1.3 | `config/mise/config.toml` (not installed by the installer) |
| rust | 1.68.2 | `config/mise/config.toml` (not installed by the installer) |
| atuin | latest | Debian family only, `config/mise/conf.d/apt-gaps.toml` (gitignored, reached as `~/.config/mise/conf.d/apt-gaps.toml`) written by `scripts/install-mise.sh` |
| github:dalance/procs | latest | Debian family only, same fragment (`procs`) |

### cargo

Rust toolchain sourced from `$CARGO_HOME/env` (`~/.local/share/cargo`).

### Homebrew (macOS + Linuxbrew)

Initialized on both macOS (`/opt/homebrew`) and Linux (`/home/linuxbrew/.linuxbrew`) when present.

---

## AI CLIs

Installed by `scripts/install-ai-clis.sh` on every OS from the vendors' own installers, not from the package lists. One that is already on `PATH` is skipped unless `--update` is given. The script sources `config/zsh/.zshenv` first, so each installer runs with `CLAUDE_CONFIG_DIR`, `CODEX_HOME`, `GEMINI_CLI_HOME` and `NPM_CONFIG_CACHE` already set and nothing lands in `~/.claude`, `~/.codex`, `~/.gemini` or `~/.npm`.

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

Loaded in order: mise, atuin, homebrew, cargo.

---

## tmux Plugins (TPM)

`scripts/install-shell.sh` clones tpm into `$TMUX_PLUGIN_MANAGER_PATH/tpm` (default branch, fast-forwarded on each rerun), and `config/tmux/tmux.conf` runs it from there. Press `prefix + I` inside tmux to install the plugins below.

| Plugin | Purpose |
|---|---|
| tmux-plugins/tpm | plugin manager |
| tmux-plugins/tmux-sensible | sensible defaults |
| tmux-plugins/tmux-resurrect | session save/restore |
| tmux-plugins/tmux-continuum | auto session restore |
| dracula/tmux | status bar theme (a switch to tmux2k is parked in `TASKS.md`) |

---

## Git Configuration

### Tools referenced in `config/git/config`

| Tool | Usage |
|---|---|
| nvim | core editor |
| git-delta | core pager — syntax-highlighted diffs |
| ssh (ed25519) | GPG signing format |

### Git aliases (`config/git/config [alias]`)

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
| `reload` / `r` | `. $ZDOTDIR/.zshrc` | reload shell config |
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

From `config/zsh/.zshenv`, read by every zsh:

| Variable | Value / Purpose |
|---|---|
| `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME` | `~/.config`, `~/.local/share`, `~/.local/state`, `~/.cache`; a value already exported wins |
| `ZDOTDIR` | `$XDG_CONFIG_HOME/zsh` |
| `DOTFILES` | `~/.dotfiles` unless already exported; `DOTFILES_BIN`, `DOTFILES_CONFIG`, `DOTFILES_ZSH`, `DOTFILES_GIT` and `DOTFILES_OVERLAYS` hang off it |
| `ZSH`, `ZSH_CUSTOM` | `$XDG_DATA_HOME/oh-my-zsh`, `$XDG_DATA_HOME/oh-my-zsh-custom` |
| `CARGO_HOME`, `RUSTUP_HOME` | `$XDG_DATA_HOME/cargo`, `$XDG_DATA_HOME/rustup` |
| `NPM_CONFIG_USERCONFIG`, `NPM_CONFIG_CACHE` | `$XDG_CONFIG_HOME/npm/npmrc`, `$XDG_CACHE_HOME/npm` |
| `TMUX_PLUGIN_MANAGER_PATH` | `$XDG_DATA_HOME/tmux/plugins` |
| `ZSHZ_DATA` | `$XDG_DATA_HOME/z/data`, the z plugin's database (the plugin creates the directory) |
| `CLAUDE_CONFIG_DIR`, `CODEX_HOME`, `GEMINI_CLI_HOME` | `$XDG_CONFIG_HOME/claude`, `$XDG_DATA_HOME/codex`, `$XDG_DATA_HOME/gemini`; `.zshrc` creates `CODEX_HOME` |
| `SHELL_SESSIONS_DISABLE` | `1`, so macOS Terminal does not write `.zsh_sessions` into `ZDOTDIR` |
| `HISTFILE`, `ZSH_COMPDUMP` | `$XDG_STATE_HOME/zsh/history`, `$XDG_CACHE_HOME/zsh/zcompdump-<version>`; set but not exported, `.zshrc` creates the directories |

From `config/zsh/.exports`:

| Variable | Value / Purpose |
|---|---|
| `HISTIGNORE` | patterns kept out of shell history (`ls`, `cd`, `date`, `* --help`) |
| `LANG` | `en_US.UTF-8` |
| `EDITOR` | `nvim` |
| `PATH` | `/usr/local/bin`, `/usr/local/sbin`, `~/.local/bin`, and `$DOTFILES_BIN` prepended; `/snap/bin` appended when present |

From `config/zsh/local.zsh`, sourced last by `.bootstrap` when the file exists (untracked, from `config/zsh/local.zsh.example`):

| Variable | Value / Purpose |
|---|---|
| `TMUX_LS_ORDER` | the order tmux session names are listed in, set per machine |

---

## Tools Referenced but NOT in Package Lists

These tools appear in aliases, configs, or init scripts but are not listed in every `packages/` file they would need to be. Expect to install them manually, from a script, or via a version manager:

| Tool | Where referenced | How it's expected |
|---|---|---|
| xclip | tmux copy-pipe | in `apt.txt` only; the clipboard rework is an open item in `TASKS.md` |
| mise | `.bootstrap` → `.mise` | in `Brewfile` and `pacman.txt`; on the Debian family `scripts/install-mise.sh` installs it from `https://mise.run` |
| atuin | `.bootstrap` → `.atuin` | in `Brewfile` and `pacman.txt`; on the Debian family through mise (`scripts/install-mise.sh`) |
| procs | alias `ps` | in `Brewfile` and `pacman.txt`; on the Debian family through mise (`scripts/install-mise.sh`) |
| node, pnpm | npm-based CLIs | installed through mise by `scripts/install-mise.sh` |
| claude, codex, gemini | run as `claude`, `codex`, `gemini` | `scripts/install-ai-clis.sh`, not in any package list |
| oh-my-zsh | `.zshrc` | cloned by `scripts/install-shell.sh` into `$ZSH` |
| powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting | `.zshrc` theme and plugins | cloned by `scripts/install-shell.sh` into `$ZSH_CUSTOM` |
| tpm | `tmux.conf` | installed by `scripts/install-shell.sh` into `$TMUX_PLUGIN_MANAGER_PATH/tpm` |
| LazyVim plugins | `config/nvim` | synced by `scripts/install-nvim.sh` when nvim is 0.11.2 or newer |
