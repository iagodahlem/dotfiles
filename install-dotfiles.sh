#!/usr/bin/env bash

readonly DOTS="$HOME/.dotfiles"
readonly VSCODE_CONFIG="$HOME/Library/Application Support/Code/User"

# Ask for the administrator password upfront
sudo -v

# Install Homebrew
if test ! $(which brew)
then
  echo " → Installing Homebrew for package management..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update
brew upgrade

echo "→ Installing packages using Homebrew..."
brew install $(cat brew/brewfile|grep -v "#")

echo "→ Configuring Git..."
ln -s "$DOTS/git/.gitconfig" ~/.gitconfig
ln -s "$DOTS/git/.gitignore_global" ~/.gitignore_global
ln -s "$DOTS/git/.gitmessage" ~/.gitmessage

echo "→ Configuring ZSH..."
echo '/usr/local/bin/zsh' | sudo tee -a /etc/shells > /dev/null
chsh -s /usr/local/bin/zsh
ln -s "$DOTS/zsh/.zshrc" ~/.zshrc
ln -s "$DOTS/zsh/.p10k.zsh" ~/.p10k.zsh

echo "→ Installing Oh My ZSH and custom plugins..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
mkdir -p ~/.custom/plugins ~/.custom/themes
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.custom/plugins/zsh-syntax-highlighting
wget https://raw.githubusercontent.com/dracula/zsh/master/dracula.zsh-theme -O ~/.custom/themes/dracula.zsh-theme

echo "→ Configuring VSCode..."
rm -rf "$VSCODE_CONFIG/{keybindings.json,settings.json}"
ln -s "$DOTS/vscode/snippets" "$VSCODE_CONFIG/snippets"
ln -s "$DOTS/vscode/keybindings.json" "$VSCODE_CONFIG/keybindings.json"
ln -s "$DOTS/vscode/settings.json" "$VSCODE_CONFIG/settings.json"

echo "→ Installing nvm..."
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
nvm install node
echo "→ Installing npm packages..."
npm install -g $(cat nmp/globals|grep -v "#")

echo "→ Configure Tmux and VIM..."
ln -s "$DOTS/tmux/.tmux.conf" ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s "$DOTS/vim/.vimrc" ~/.vimrc

echo "→ Installing asdf..."
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.1
asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
echo "→ Configure asdf..."
ln -s "$DOTS/asdf/.tool-versions" ~/.tool-versions
ln -s "$DOTS/asdf/.asdfrc" ~/.asdfrc

# Set macOS defaults
echo "→ Set macOS defaults... (It'll shut down Terminal!)"
sh macos.sh
