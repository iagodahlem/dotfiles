export HISTIGNORE="ls:ls *:cd:cd -:pwd;exit:date:* --help"

# prefer US English and use UTF-8
export LANG=en_US.UTF-8

# editors
export EDITOR='nvim'

# path
# Build PATH — prepend local dirs, keep system PATH intact
PATH=/usr/local/bin:/usr/local/sbin:$PATH
PATH=$HOME/.local/bin:$PATH
PATH=$DOTFILES_BIN:$PATH
[ -d /snap/bin ] && PATH=$PATH:/snap/bin
export PATH
