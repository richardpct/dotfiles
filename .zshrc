# oh-my-zsh configuration
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="richardpct"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export VIRTUAL_ENV_DISABLE_PROMPT=1

if [ `uname -m` = 'arm64' ] && [ -f /usr/local/bin/brew ]; then
  PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin
fi

if [ `uname` = 'Darwin' ]; then
  export CLICOLOR=1
  export LSCOLORS='exfxcxdxcxegedabagacad'
fi

alias tmux='tmux -u'
alias grep='grep --color'
alias ubuntu='docker run -it --rm ubuntu /bin/bash'
alias k="kubectl"

if [ -f ${HOME}/.kubectl_completion ]; then
  source ${HOME}/.kubectl_completion
fi

function gimp {
  DOCKER_GIMP_REPO="${HOME}/github/docker-gimp"

  if [ -d $DOCKER_GIMP_REPO ]; then
    (
      cd $DOCKER_GIMP_REPO
      make run
    )
  else
    echo "$DOCKER_GIMP_REPO repository does not exist"
  fi
}

function geeqie {
  DOCKER_GEEQIE_REPO="${HOME}/github/docker-geeqie"

  if [ -d $DOCKER_GEEQIE_REPO ]; then
    (
      cd $DOCKER_GEEQIE_REPO
      make run
    )
  else
    echo "$DOCKER_GEEQIE_REPO repository does not exist"
  fi
}
