# Clipboard

How copy and paste work between the Mac and the headless Arch box (`hades`) over ssh, what is
broken today, and the plan to fix it.

## The problem

Three contexts, two directions:

| Direction | Context | State |
| --- | --- | --- |
| hades to Mac | plain ssh | no clipboard tool on hades, nothing to copy into |
| hades to Mac | tmux | copy binding pipes to `xclip`, which is not installed |
| hades to Mac | agent CLI (Claude Code) | `/dev/tty` is not available to its shell tool |
| Mac to hades | any | text pastes fine, images and files do not paste at all |

## What the terminal can and cannot do

`OSC 52` is the only clipboard mechanism that crosses ssh. It is an escape sequence: hades writes
it, tmux forwards it, Ghostty applies it to the macOS clipboard. It carries **text only**. There is
no escape sequence for image or file data, so images and video can never arrive through the
clipboard path. They need a file transfer.

The Kitty graphics protocol that Ghostty implements is the opposite direction: it renders images
into the terminal. It is not a paste channel.

Agent CLIs running on hades read the *hades* clipboard, which is headless and always empty.
Installing a clipboard tool there does not help. It is the wrong machine.

## Audit, 2026-08-31

- hades has no `xclip`, no `xsel`, no `wl-copy`, and no X or Wayland session.
- `config/tmux/.tmux.conf` binds copy-mode `y` to `copy-pipe-and-cancel 'xclip -in -selection clipboard'`.
  The binary does not exist on hades, so the copy silently goes nowhere.
- tmux runtime had `set-clipboard external` and `mouse off`.
- tmux reports the client terminal as `xterm-256color`, not `xterm-ghostty`. The `xterm-ghostty`
  terminfo entry is missing on hades. This does not block the clipboard, because tmux matches
  `xterm*` for the clipboard capability, but it is worth fixing separately.
- Claude Code's shell tool has no `/dev/tty`, so raw `OSC 52` writes fail there. `$TMUX` is set,
  so the tmux route works.
- Remote Login is enabled on the Mac and reachable from the Linux box, but the `hades-to-mac` key
  was never added to `authorized_keys`, so key auth still fails.
- The Mac's address moved between LAN leases, so it is on DHCP drift.

## Fix 1: text, hades to Mac

In `config/tmux/.tmux.conf`, drop the `xclip` dependency and let tmux emit `OSC 52` itself:

```tmux
set -g set-clipboard on
set -g mouse on
bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
```

With `mouse on`, tmux owns mouse drags. Hold Shift to fall back to the terminal's own selection
when you want to select across a pane border.

In `overlays/host/hades/zsh/.functions`, add a `pbcopy` equivalent:

```sh
copy() {
  local data; data=$(cat "$@")
  if [ -n "$TMUX" ]; then
    printf '%s' "$data" | tmux load-buffer -w -
  elif : > /dev/tty 2>/dev/null; then
    printf '\033]52;c;%s\a' "$(printf '%s' "$data" | base64 -w0)" > /dev/tty
  else
    echo "copy: no clipboard transport" >&2; return 1
  fi
}
alias pbcopy=copy
```

The tmux branch is first on purpose: it is the only one that works from an agent CLI's shell tool.

Caveats: terminals drop `OSC 52` payloads above a few hundred KB, and `set-clipboard on` lets any
program that emits the sequence write the Mac clipboard.

## Fix 2: images and files, Mac to hades

This is a file bridge, not a clipboard fix. hades pulls from the Mac, which means it also works
from inside an agent session with no extra window.

Prerequisites, on the Mac:

```sh
cat ~/.ssh/hades-to-mac.pub   # on the Linux box; paste that line into the Mac's ~/.ssh/authorized_keys
brew install pngpaste
```

Then in `overlays/host/hades/zsh/.functions`:

```sh
# screenshot on the Mac (Cmd+Shift+4), then run this on hades
clip() {
  local dest="$HOME/inbox/clip/$(date +%Y%m%dT%H%M%S).png"
  mkdir -p "${dest%/*}"
  ssh -i ~/.ssh/hades-to-mac mac 'pngpaste -' > "$dest" \
    || { rm -f "$dest"; echo "clip: no image on Mac clipboard" >&2; return 1; }
  echo "$dest"
}

# drag a file into the terminal, it inserts the Mac path, prefix it with this
mac() {
  local dest="$HOME/inbox/clip/${1##*/}"
  mkdir -p "${dest%/*}"
  scp -i ~/.ssh/hades-to-mac "mac:$1" "$dest" >/dev/null && echo "$dest"
}
```

`clip` covers screenshots. `mac` covers video and anything else, with no size ceiling because it is
`scp` rather than an escape sequence. Both are reads against the Mac; nothing writes to it.

Add `pngpaste` to `packages/Brewfile` so a fresh Mac install has it.

## Open items

- Reserve the Mac's address in the router and add a Pi-hole entry so `mac` is a stable name rather
  than an IP that moves.
- Install the `xterm-ghostty` terminfo on hades, either with Ghostty's `ssh-terminfo` shell
  integration feature or manually:

  ```sh
  infocmp -x xterm-ghostty | ssh hades -- tic -x -
  ```

- Rename the existing local key pair from its old name to `~/.ssh/hades-to-mac` before applying, it was never authorized so nothing depends on it.
- Confirm the Mac username. Three guesses failed at the key stage, so it is still unverified.
- Verify the text path end to end once `set-clipboard on` is applied.
