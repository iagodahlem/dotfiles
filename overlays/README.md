# Overlays

Overlays provide optional, OS- or host-specific tweaks without separate repositories.

## Structure

- `overlays/os/<id>/` for OS-specific config, where `<id>` is the value of `os_id` (`macos`, `ubuntu`, `debian`, `arch`)
- `overlays/host/<name>/` for host-specific config (set `DOTFILES_HOST=<name>`)

The loader (`load_overlay` in `config/zsh/.bootstrap`) reads only `overlays/os/<id>/zsh/*` and `overlays/host/<name>/zsh/*`, sourcing `.exports`, `.aliases`, `.functions`, and `.bootstrap` from each when present, and ignores anything else under an overlay.

Example:

```text
overlays/os/ubuntu/zsh/.aliases
overlays/host/work-laptop/zsh/.exports
```
