# mini dotfiles

The work machine, used as a desk server: reached over ssh and mosh.

Its overlay carries a `Brewfile` with Rancher Desktop (the container runtime for this machine) and no `git/config`: there is nothing host-specific for git here, and the identity for this machine lives in this repo's gitignored `config/git/local` (see `config/git/local.example` and "One machine, one identity" in `docs/new-mac.md`), copied by hand on the machine, never committed. The other thing it carries is `install.sh`, the installer's `host` step: it keeps the machine awake, and since Rancher Desktop only runs here, it also owns everything Rancher-specific that the shared dotfiles stay agnostic about (PATH, the docker CLI's config).

This overlay lives in this repo rather than a private one: the mini is a work machine and should not be pulling a private overlays repo at all, so `DOTFILES_PRIVATE_REPO` stays unset on it and `host_overlay_dir` (`scripts/utils/host.sh`) falls straight through to `overlays/host/mini/` once the hostname resolves to `mini`.

## install.sh: keep the mini awake

macOS puts an idle mini to sleep, and that breaks mosh. mosh talks UDP, and a UDP packet cannot wake a sleeping Mac; only a TCP connection through the sleep proxy can. So an ssh login wakes the machine, but a mosh session that was already open freezes when the mini sleeps and only comes back once something else wakes it.

The hook sets these on AC power only (`pmset -c`), the mini being always plugged in:

| Key | Value | Why |
| --- | --- | --- |
| `sleep` | `0` | never sleep the system, so there is always a machine for mosh to talk to |
| `displaysleep` | `15` | the display still turns off after 15 minutes; the machine stays up |
| `womp` | `1` | "Wake for network access": the sleep proxy can still wake it for a TCP connection if it is put to sleep by hand |
| `disksleep` | `0` | no disk spin-down |

The keys and the `-c` (charger) and `-g custom` flags are as in Apple's `pmset` man page, [pmset(1)](https://keith.github.io/xcode-man-pages/pmset.1.html), which also says `pmset` must run as root to change a setting.

How it works:

- Each value is read from the "AC Power" block of `pmset -g custom` and set with `sudo pmset -c <key> <value>` only when it differs, so a rerun on a configured mini changes nothing and asks for no password.
- One line per setting: `pmset -c sleep: 1 -> 0` when it changes, `pmset -c sleep already 0` when it does not.
- `DOTFILES_DRY_RUN=1` (or `--dry-run` on the installer) prints `would run: sudo pmset -c ...` for each setting that differs and changes nothing.
- The last lines are the resulting "AC Power" block of `pmset -g custom`.
- On a machine with no `pmset`, it says so and exits 0.

## install.sh: ~/.rd/bin on PATH

Rancher Desktop only runs on this machine, so the shared dotfiles stay Rancher-agnostic and this hook puts `~/.rd/bin` on PATH itself, through an `/etc/paths.d/rancher-desktop` file holding that one absolute path, written with `sudo tee` only when its content differs from what `~/.rd/bin` resolves to (same diff-first, `DOTFILES_DRY_RUN`-aware style as the pmset hook above), and left alone entirely when `~/.rd/bin` does not exist.

`/etc/paths.d` is macOS's own mechanism, not a dotfiles one: `path_helper`, run from `/etc/zprofile`, folds every file there into PATH ahead of anything a shell adds on its own. That covers every login shell this machine actually uses: a new Terminal window, a tmux window (tmux starts one, since `config/tmux/tmux.conf` leaves `default-command` unset), and an interactive ssh session. It does not cover the non-login, non-interactive shell ssh runs for a single command (`mosh-server`, `scp`, git over ssh), which reads `~/.zshenv` only, the same gap that file's own Homebrew PATH prepend documents (see "How Config Loads" in `AGENTS.md`); nothing here needs Rancher's bin in that narrow case.

Homebrew's own `/opt/homebrew/bin` already travels the same way (there is an `/etc/paths.d/homebrew` on this machine), and `config/brew/init.zsh`'s full `brew shellenv` still re-prepends it ahead of everything at the interactive-shell stage (ending in `typeset -U path`, which dedupes but never reorders), so adding this file does not move Homebrew, mise, or any other dotfiles-managed PATH entry from where they already were: `~/.rd/bin` only ever lands after them.

## install.sh: Rancher Desktop's PATH management stays off

Rancher Desktop also defaults to managing PATH itself ("rcfiles"): it writes `~/.rd/bin` into `~/.zshrc`, `~/.bashrc`, `~/.bash_profile`, `~/.cshrc` and `~/.tcshrc` on every start, and rewrites them if it finds its block missing, which would fight the `/etc/paths.d` entry above and litter rc files this machine does not read. So this hook sets Rancher's own strategy to `manual` instead, with `rdctl set --application.path-management-strategy=manual`.

The current value is read straight from `~/Library/Preferences/rancher-desktop/settings.json` (`.application.pathManagementStrategy`; `~/Library/Application Support/rancher-desktop` only holds the VM and its images, not settings) with `jq`, so the hook can report it even with Rancher Desktop closed. Only the actual change needs the app running, since `rdctl set` talks to its local API: with Rancher Desktop not installed, not yet run once (no `~/.rd/bin/rdctl` yet) or not currently running, it says so and leaves the setting alone.

## install.sh: clearing the rc files Rancher Desktop left behind

Every rerun of the hook above also looks at `~/.zshrc`, `~/.bashrc`, `~/.bash_profile`, `~/.cshrc` and `~/.tcshrc`: a file holding nothing but Rancher's `### MANAGED BY RANCHER DESKTOP START/END (DO NOT EDIT)` block (blank lines aside) is backed up to `<name>.bak.<timestamp>`, the same convention `install-dotfiles.sh`'s `safe_link` uses, and removed. `~/.zshrc` is dead weight on this machine either way: zsh reads `$ZDOTDIR/.zshrc` once `ZDOTDIR` is set, never `~/.zshrc` (see `legacy_leave_reason` in `scripts/install-dotfiles.sh`), and none of the other four shells are used here. A file with anything else in it, Rancher's block or not, is left alone and warned about.

## install.sh: the docker CLI's rancher-desktop context

Installing Rancher Desktop never points the docker CLI at it: `docker` keeps using whatever context it already had, and Rancher's own backend writes its context straight into `~/.docker` regardless of `DOCKER_CONFIG` (see the main `README.md`, "The home directory after an install"). This hook creates a `rancher-desktop` context for `~/.rd/docker.sock` when it is missing, through the docker CLI itself, resolving `DOCKER_CONFIG` through `resolve_zshenv_vars` (`scripts/utils/zshenv.sh`) the same way a zsh login shell would, so it lands under the directory `config/zsh/.zshenv` redirects it to. It only switches to that context when the current one is not reachable via a bounded `docker info` probe (checking both that the context exists and that it responds), so a working OrbStack, Docker Desktop, or remote (`ssh://` or `tcp://`) context is left alone; with no `~/.rd/docker.sock` (Rancher Desktop not installed, or not running), it leaves the context alone entirely.

Run it on the mini with the installer's `host` step:

```bash
bash ~/.dotfiles/scripts/install.sh --only host
```
