#!/usr/bin/env bash
# macOS defaults that still apply on a current Mac, each with the reason for it.
# Run by scripts/install.sh, or on its own. With DOTFILES_DRY_RUN=1 it prints the commands instead of running them.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/scripts/utils/dry-run.sh"

# Save to disk, not to iCloud, by default
run defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Full keyboard access, so Tab reaches every control in dialogs
run defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Fast key repeat, and a short wait before it starts
run defaults write NSGlobalDomain KeyRepeat -int 2
run defaults write NSGlobalDomain InitialKeyRepeat -int 15

# No smart quotes, they get in the way when typing code
run defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# No smart dashes, same reason
run defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# No autocorrect
run defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Chrome: no back and forward navigation on a horizontal scroll
run defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

# Screenshots go to ~/Pictures/Screenshots
run mkdir -p "$HOME/Pictures/Screenshots"
run defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# Screenshots as PNG
run defaults write com.apple.screencapture type -string png

# Dock on the right
run defaults write com.apple.dock orientation -string right

# Minimize windows into their application's icon
run defaults write com.apple.dock minimize-to-application -bool true

# No recent applications in the Dock
run defaults write com.apple.dock show-recents -bool false

# Smaller Dock icons, 48 instead of the default 64
run defaults write com.apple.dock tilesize -int 48

# Clicking the wallpaper reveals the desktop only in Stage Manager, not always
run defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Allow quitting Finder with Cmd+Q
run defaults write com.apple.finder QuitMenuItem -bool true

# No icons for drives, servers and removable media on the desktop
run defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
run defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
run defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
run defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Show hidden files
run defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Restart automatically if the computer freezes. The one line that needs sudo, so a failure here does not stop the rest
run sudo systemsetup -setrestartfreeze on || echo "warning: sudo systemsetup -setrestartfreeze on failed, run it by hand" >&2

# Restart what shows the settings above, each on its own so one that is not running does not skip the others
for app in Finder Dock SystemUIServer; do
  run killall "$app" 2>/dev/null || true
done

echo "Key repeat applies after the next login."
