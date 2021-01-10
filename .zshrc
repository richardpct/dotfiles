# oh-my-zsh configuration
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="richardpct"
plugins=(git)
source $ZSH/oh-my-zsh.sh

if [ `uname` = 'Darwin' ]; then
  export CLICOLOR=1
  export LSCOLORS='exfxcxdxcxegedabagacad'
fi

alias tmux='tmux -u'
alias grep='grep --color'
alias ubuntu='docker run -it --rm ubuntu /bin/bash'

if [ -f ${HOME}/.kubectl_completion ]; then
  source ${HOME}/.kubectl_completion
fi
