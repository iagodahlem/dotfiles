#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Install Homebrew
if test ! $(which brew)
then
  echo " → Installing Homebrew for package management..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "→ Installing applications..."
# Set up Cask taps
brew tap homebrew/cask || true
brew tap homebrew/cask-versions || true

if [ -f packages/Caskfile ]; then
  brew install --cask $(grep -v "^#" packages/Caskfile)
else
  echo "→ Skipping apps: packages/Caskfile not found."
fi

echo "→ Installing fonts..."
# Set up font casks
brew tap homebrew/cask-fonts || true

if [ -f packages/Fontfile ]; then
  brew install --cask $(grep -v "^#" packages/Fontfile)
else
  echo "→ Skipping fonts: packages/Fontfile not found."
fi
