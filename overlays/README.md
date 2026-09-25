# Overlays

Overlays provide optional, OS- or host-specific tweaks without separate repositories.

## Structure

- `overlays/os/<id>/` for OS-specific config, where `<id>` is the value of `os_id` (`macos`, `ubuntu`, `debian`, `arch`; older 32-bit Raspberry Pi OS reports `raspbian` and has no overlay of its own)
- `overlays/host/<name>/` for host-specific config (set `DOTFILES_HOST=<name>`)

The loader (`load_overlay` in `config/zsh/.bootstrap`) reads only `overlays/os/<id>/zsh/*` and `overlays/host/<name>/zsh/*`, sourcing `.exports`, `.aliases`, `.functions`, and `.bootstrap` from each when present, and ignores anything else under an overlay.

A host overlay can also carry a `Brewfile` (`overlays/host/<name>/Brewfile`). On macOS `scripts/install-packages.sh` applies it with `brew bundle` after the core `packages/Brewfile`, picking `<name>` from `DOTFILES_HOST` or `hostname -s`. A Brewfile with no entries is skipped. The shell loader ignores it.

Example:

```text
overlays/os/ubuntu/zsh/.aliases
overlays/host/work-laptop/zsh/.exports
overlays/host/mac/Brewfile
```
