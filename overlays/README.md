# Overlays

Overlays provide optional, OS- or host-specific tweaks without separate repositories.

## Structure

- `overlays/os/<os>/` for OS-specific config
- `overlays/host/<name>/` for host-specific config (set `DOTFILES_HOST=<name>`)

Each overlay can contain the same layout as `config/`, e.g.:

```
overlays/os/ubuntu/zsh/.aliases
overlays/host/work-laptop/zsh/.exports
```

Only existing files are loaded.
