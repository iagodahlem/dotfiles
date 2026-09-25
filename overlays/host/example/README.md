# Host Overlay Example

Set `DOTFILES_HOST=example` to load this overlay.

Place host-specific files under `overlays/host/<name>/` matching the `config/` layout, e.g.:

- `overlays/host/example/zsh/.aliases`
- `overlays/host/example/zsh/.exports`
- `overlays/host/example/Brewfile` (extra formulae and casks for this host on macOS, in `brew bundle` syntax)
