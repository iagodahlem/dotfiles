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
| zsh login-shell hook | `config/zsh/.zprofile` | `~/.config/zsh/.zprofile`, reached through the directory link | `ZDOTDIR`, read by login shells only; holds OrbStack's shell init (`source ~/.orbstack/shell/init.zsh 2>/dev/null \|\| :`), which its first launch appends to the login profile |
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
| git identity and host settings | none, untracked and gitignored (`local.example` is the template; `host` is a link to the `git/config` of the host overlay, made by `scripts/install-dotfiles.sh`) | `config/git/local`, `config/git/host` in the checkout, reached as `~/.config/git/local` and `~/.config/git/host` | none, included by path from `config` |
| private overlays | none, a checkout of a private repo, cloned by `scripts/install-private.sh` | `~/.machines`, with the overlay of each machine in `<name>/dotfiles/` | `DOTFILES_PRIVATE` |
| ghostty | `config/ghostty/` | `~/.config/ghostty` (directory link) | `XDG_CONFIG_HOME` |
| karabiner-elements | `config/karabiner/` | `~/.config/karabiner` (directory link, macOS only) | none, `~/.config` is where it looks by default |
| karabiner backups | none, untracked and gitignored, written by Karabiner-Elements | `config/karabiner/automatic_backups/` in the checkout, reached as `~/.config/karabiner/automatic_backups/` | none |
| neovim config | `config/nvim/` | `~/.config/nvim` (directory link) | `XDG_CONFIG_HOME` |
| neovim plugins | none, synced by `scripts/install-nvim.sh` | `~/.local/share/nvim` | `XDG_DATA_HOME` |
| mise | `config/mise/` | `~/.config/mise` (directory link) | `XDG_CONFIG_HOME` |
| mise Debian fragment | none, untracked and gitignored, written by `scripts/install-mise.sh` on the Debian family | `config/mise/conf.d/` in the checkout, reached as `~/.config/mise/conf.d/` | none, mise loads `conf.d/*.toml` from its config directory |
| bun | `config/mise/config.toml` (`bun = "latest"`), installed by mise | the binary under `~/.local/share/mise/installs/bun/`; the package cache is still `~/.bun/install/cache`, an open item in `TASKS.md` (`BUN_INSTALL_CACHE_DIR` would move it) | `XDG_DATA_HOME` for the binary, none for the cache |
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

`packages/Brewfile` (53 entries) is applied with `brew bundle` on every Mac. `brew bundle` skips an app that already exists outside Homebrew and keeps going. The `Brewfile` in the host overlay of this machine, when it has one (see Host overlay below), is applied on top of it.

**Formulae** (26):

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
| nmap | port scanner |
| procs | modern ps replacement |
| ripgrep | grep replacement |
| rtk | compresses noisy command output |
| speedtest-cli | internet speed test |
| tmux | terminal multiplexer |
| zsh | Z shell |

**Casks** (25):

| App | Description |
|---|---|
| 1password | password manager |
| 1password-cli | 1Password command line client |
| bartender | menu bar icon organiser |
| bettertouchtool | trackpad, mouse and keyboard gestures |
| cleanshot | screenshots and screen recordings |
| codexbar | menu bar usage monitor |
| ghostty | GPU-accelerated terminal emulator |
| google-chrome | web browser |
| granola | meeting notes |
| karabiner-elements | keyboard customizer |
| keepingyouawake | keeps the Mac from sleeping |
| logi-options+ | Logitech mouse and keyboard settings (its cask says to reboot to finish the install) |
| notion-calendar | calendar |
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

**Host overlay Brewfile**: the overlay of a machine may hold a `Brewfile` of its own, applied after the core one. Those overlays are private, so what they add is not listed here; `overlays/host/example/Brewfile` is the shape.

### Debian / Raspberry Pi OS / Ubuntu (apt)

`packages/apt.txt` (33) is installed in one `apt-get install --no-install-recommends` after `scripts/install-apt-repos.sh` adds the third-party sources below. A package with no candidate on the running release is skipped with a warning (`fastfetch` needs Debian 13 or newer, for instance). The `packages/apt.txt` of the host overlay, when it has one with entries, is installed the same way right after it, with the same candidate check.

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

`mise` comes from its installer and `atuin` and `procs` through mise, see [Version Managers & Runtimes](#version-managers--runtimes). LaTeX is not in the list, and TinyTeX is not an install path: a host that needs it lists its texlive packages in its overlay's `packages/apt.txt`.

**Third-party apt repositories** (added by `scripts/install-apt-repos.sh`, each skipped when its sources file already exists):

| Repository | Provides | Sources file | Key |
|---|---|---|---|
| `download.docker.com/linux/debian` (`ubuntu` on Ubuntu) | docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin | `docker.sources` | `/etc/apt/keyrings/docker.asc` |
| `pkgs.tailscale.com/stable/debian` (`ubuntu` on Ubuntu) | tailscale | `tailscale.sources` | `/usr/share/keyrings/tailscale-archive-keyring.gpg` |
| `deb.gierens.de` | eza | `gierens.sources` | `/etc/apt/keyrings/gierens.asc` |
| `packages.azlux.fr/debian` | docker-ctop | `azlux.sources` | `/usr/share/keyrings/azlux-archive-keyring.gpg` |

### Arch Linux (pacman)

`packages/pacman.txt` (38) is installed in one `pacman -Syu --needed` transaction. The `packages/pacman.txt` of the host overlay, when it has one with entries, follows in a second `pacman -S --needed --noconfirm` call (the full upgrade already ran, and a name pacman does not know only costs that call: it warns and the AUR step still runs). LaTeX is not in the list either: texlive packages go in the overlay's list.

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

`scripts/install.sh` runs the OS defaults script as its `os-defaults` step (`--only os-defaults` runs just that, `--dry-run` prints the commands).

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
| `com.apple.screencapture` | `location` | `~/Pictures/Screenshots` | screenshots go there (the script creates the folder) |
| `com.apple.screencapture` | `type` | `png` | screenshots as PNG |
| `com.apple.dock` | `orientation` | `right` | Dock on the right |
| `com.apple.dock` | `minimize-to-application` | `true` | windows minimize into their application's icon |
| `com.apple.dock` | `show-recents` | `false` | no recent applications in the Dock |
| `com.apple.dock` | `tilesize` | `48` | smaller Dock icons (the default is 64) |
| `com.apple.WindowManager` | `EnableStandardClickToShowDesktop` | `false` | clicking the wallpaper reveals the desktop only in Stage Manager, not always |
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

## Host overlay

The overlay of one machine holds what that machine needs beyond the shared config. `host_overlay_dir` in `scripts/utils/host.sh` finds it for the host named by `DOTFILES_HOST` (the short hostname in lower case, detected in `config/zsh/.zshenv`), and the shell loader, the git link, the host Brewfile and package lists and the host step all go through it. It takes the first directory that exists:

1. `$DOTFILES_PRIVATE/<name>/dotfiles/`: the private overlays repo, checked out at `~/.machines`, which the `private` step clones from `DOTFILES_PRIVATE_REPO` (ssh form, never written in this repo) and pulls on later runs.
2. `overlays/host/<name>/`: an overlay kept in this repo.

The real overlays are private, so nothing here says what a machine carries. `overlays/host/example/` has one file of each kind and `overlays/README.md` lists what reads each of them:

| File in the overlay | What it does |
|---|---|
| `zsh/.exports`, `.aliases`, `.functions`, `.zshrc.local`, `.bootstrap` | sourced by `config/zsh/.bootstrap` after the OS overlay, in that order |
| `git/config` | linked as `config/git/host`, which git includes before `config/git/local` |
| `Brewfile` | applied by `brew bundle` on macOS, after `packages/Brewfile`; skipped while it has no entries |
| `packages/pacman.txt` | installed on Arch after `packages/pacman.txt`, in a second `pacman -S --needed --noconfirm` call; skipped while it has no entries |
| `packages/apt.txt` | installed on the Debian family after `packages/apt.txt`, skipping a package with no candidate on the release; skipped while it has no entries |
| `install.sh` | run by the `host` step, the last one, with `DOTFILES_DRY_RUN=1` on a dry run; a failure only warns |

| Variable | Purpose |
|---|---|
| `DOTFILES_HOST` | the name of this machine, the short hostname in lower case unless already set |
| `DOTFILES_PRIVATE` | where the private overlays repo is checked out, `~/.machines` unless already set |
| `DOTFILES_PRIVATE_REPO` | the private overlays repo to clone, in the ssh form; empty means private overlays are off |
| `DOTFILES_SKIP_PRIVATE`, `DOTFILES_SKIP_HOST` | skip the `private` step, or the host hook |

---

## Version Managers & Runtimes

### mise (`config/mise/`)

Activated first on shell start. `mise` itself comes from `packages/Brewfile` on macOS, `packages/pacman.txt` on Arch, and `https://mise.run` on the Debian family. `scripts/install-mise.sh` installs the tools below, then runs `corepack enable`.

| Tool | Version | Where it is declared |
|---|---|---|
| node | lts | `config/mise/config.toml` |
| pnpm | latest | `config/mise/config.toml` |
| bun | latest | `config/mise/config.toml` |
| go | 1.23.4 | `config/mise/config.toml` (not installed by the installer) |
| ruby | 3.1.3 | `config/mise/config.toml` (not installed by the installer) |
| rust | 1.68.2 | `config/mise/config.toml` (not installed by the installer) |
| atuin | latest | Debian family only, `config/mise/conf.d/apt-gaps.toml` (gitignored, reached as `~/.config/mise/conf.d/apt-gaps.toml`) written by `scripts/install-mise.sh` |
| github:dalance/procs | latest | Debian family only, same fragment (`procs`) |

### cargo

Rust toolchain sourced from `$CARGO_HOME/env` (`~/.local/share/cargo`).

### Homebrew (macOS + Linuxbrew)

Initialized on both macOS (`/opt/homebrew`) and Linux (`/home/linuxbrew/.linuxbrew`) when present. `config/brew/.homebrew` runs the full `brew shellenv` for interactive shells and ends with `typeset -U path`. `config/zsh/.zshenv` also prepends the `bin` directory to `PATH` for every zsh, so an ssh command (`mosh-server`, `scp`, git over ssh), which runs a non-interactive shell that reads only `.zshenv`, finds what Homebrew installed.

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

### Theme

Powerlevel10k (`powerlevel10k/powerlevel10k`) with instant prompt and custom `.p10k.zsh`.

### Tool initialization (via `.bootstrap`)

Loaded in order: mise, atuin, homebrew, cargo.

### Startup benchmark (`ci/shell-startup.sh`)

Times `zsh -i -c exit` and prints numbers, gating nothing. It measures whatever `$HOME` is, so there are two invocations:

| Invocation | What it measures |
|---|---|
| `ci/shell-startup.sh` | the real home, as it is |
| `HOME=<scratch> ci/shell-startup.sh` | a scratch home with the checkout linked as `~/.dotfiles`, `~/.zshenv` and `~/.config/zsh`, and oh-my-zsh cloned (`scripts/install.sh --only dotfiles --only shell` with `HOME=<scratch>` builds one, see the README) |

| Flag | Effect |
|---|---|
| `-n <runs>` | number of timed shells, 10 by default; prints the min, median and max in milliseconds |
| `--profile` | one shell under `zsh/zprof`, prints the 15 entries with the most self time (shell functions only: what `mise`, `atuin` and `brew` spend in their own processes is charged to the code that ran them) |

Two shells run first and are not counted, since the first ones in a home build and compile the completion dump. Every shell starts from `$HOME` with `XDG_*`, `ZDOTDIR`, `DOTFILES` and `DOTFILES_PRIVATE` removed from the environment, so a terminal that has them set cannot point a scratch home at the real one. The script refuses a home with no `~/.zshenv` link or no oh-my-zsh, whose shell would start much faster than the setup it is meant to measure. CI runs it inside the Ubuntu image (job `shell-startup`), where there is no mise, atuin or Homebrew.

Baseline, measured on Arch in a scratch home (oh-my-zsh, Powerlevel10k, mise with node, pnpm and bun, atuin, Linuxbrew) with 60 interleaved rounds per row, each row switching one block off; the median of the whole startup was 89.3 ms. The blocks overlap a little, so the rows do not add up exactly:

| Block | Cost | Share |
|---|---|---|
| mise (`mise activate zsh` and the `hook-env` it runs once) | 20.7 ms | 23% |
| the ten oh-my-zsh plugins | 20.0 ms | 22% |
| of which zsh-syntax-highlighting, git, z | 7.0, 3.5 and 3.3 ms | 8%, 4% and 4% |
| of which the other seven | 1.6 ms or less each | |
| compinit (oh-my-zsh's, with its two compaudit checks) | 7.6 ms | 9% |
| of which the checks, which `ZSH_DISABLE_COMPFIX=true` skips | 3.0 ms | 3% |
| atuin (`atuin init zsh --disable-up-arrow`) | 7.5 ms | 8% |
| `brew shellenv` | 5.9 ms | 7% |
| overlay loading in `.bootstrap` (`os_id`, `host_overlay_dir`) | 3.7 ms | 4% |
| Powerlevel10k theme and `.p10k.zsh` | 3.2 ms | 4% |
| Powerlevel10k instant prompt | 0.2 ms | 0% |
| cargo env | 0.0 ms | 0% |
| the rest: oh-my-zsh's own libraries, `.aliases`, zsh itself | about 19 ms | 21% |

Without mise the median is 65 ms, and the Ubuntu image, with oh-my-zsh and Powerlevel10k only, measured 68 ms before `skip_global_compinit=1` and 56 ms after it. The benchmark ends before the first prompt. On a pty, a shell that has `echo` typed ahead answers about 154 ms after it starts, and switching a block off there saves 34 ms for mise (14 more than at startup: its `precmd` hook runs `hook-env` again before every prompt) and 29 ms for Powerlevel10k (25 more: drawing the first prompt). Powerlevel10k's instant prompt paints the first prompt at 5 ms instead of 94 ms for about 5 ms of readiness, so it stays.

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
| `PATH` | `/opt/homebrew/bin` and `/home/linuxbrew/.linuxbrew/bin` prepended when the directory exists and is not on `PATH` already, for shells that never read `.zshrc` (ssh commands) |
| `DOTFILES` | `~/.dotfiles` unless already exported; `DOTFILES_BIN`, `DOTFILES_CONFIG`, `DOTFILES_ZSH`, `DOTFILES_GIT` and `DOTFILES_OVERLAYS` hang off it |
| `DOTFILES_HOST` | the short hostname in lower case unless already exported, the name of the host overlay (see Host overlay) |
| `DOTFILES_PRIVATE` | `~/.machines` unless already exported, the checkout of the private overlays repo |
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
| node, pnpm, bun | npm-based CLIs, and bun for its own scripts | installed through mise by `scripts/install-mise.sh` |
| claude, codex, gemini | run as `claude`, `codex`, `gemini` | `scripts/install-ai-clis.sh`, not in any package list |
| oh-my-zsh | `.zshrc` | cloned by `scripts/install-shell.sh` into `$ZSH` |
| powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting | `.zshrc` theme and plugins | cloned by `scripts/install-shell.sh` into `$ZSH_CUSTOM` |
| tpm | `tmux.conf` | installed by `scripts/install-shell.sh` into `$TMUX_PLUGIN_MANAGER_PATH/tpm` |
| LazyVim plugins | `config/nvim` | synced by `scripts/install-nvim.sh` when nvim is 0.11.2 or newer |
