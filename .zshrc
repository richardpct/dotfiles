autoload -Uz compinit
compinit

if [ `uname` = 'Darwin' ]; then
  export CLICOLOR=1
  export LSCOLORS='exfxcxdxcxegedabagacad'
fi

if [ -x ${HOME}/opt/bin/make ]; then
  alias make='${HOME}/opt/bin/make'
fi

if [ -f ${HOME}/.kubectl_completion ]; then
  source ${HOME}/.kubectl_completion
fi

function precmd() {
  if [ -f ${HOME}/.git-prompt.sh ]; then
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    source ${HOME}/.git-prompt.sh
    __git_ps1 "%F{magenta}%~%B%F{magenta}" "%b%F{white} » %b%f" " (%s)"
  else
    PROMPT='%F{magenta}%~ %B%F{white}» %b%f'
  fi
}

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
