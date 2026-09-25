# Host Overlay Example

The shape of a host overlay, with one commented line in each file. `DOTFILES_HOST=example` loads it on any machine, and `overlays/README.md` says where an overlay is looked for and what reads each file.

The real overlays live in a private repo, one folder per machine, and the overlay of a machine is its `<name>/dotfiles/` folder there. The same shape works under `overlays/host/<name>/` in this repo, which is used only when the private repo has no folder for the host.

- `zsh/.exports`, `zsh/.aliases`, `zsh/.functions`: exports, aliases and functions for this host
- `zsh/.zshrc.local`: shell lines that are none of those three
- `zsh/.bootstrap`: whatever has to run after the rest of the overlay
- `git/config`: git settings for this host, linked as `config/git/host`
- `Brewfile`: extra formulae and casks for this host on macOS, in `brew bundle` syntax
- `install.sh`: setup only this host needs, run as the installer's `host` step, the last one
