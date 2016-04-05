#
# ZSH Config
# ---------------------------------------------------------------------

export ZSH=/home/iago/.oh-my-zsh

EDITOR="subl"
ZSH_THEME="dracula"
ZSH_CUSTOM="$HOME/.custom"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(gitfast git-tools history-substring-search sublime node npm zsh-syntax-highlighting z)
# Not needed plugins but very useful
# git git-extras git-prompt

source $ZSH/oh-my-zsh.sh
source $ZSH_CUSTOM/.extras
source $ZSH_CUSTOM/.aliases
source $ZSH_CUSTOM/.functions
eval "$(thefuck --alias)"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export SSH_KEY_PATH="~/.ssh/dsa_id"
export NVM_DIR="/home/iago/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm