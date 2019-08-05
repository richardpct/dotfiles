# DEFAULT Normal '\[\033[00m\]'
# DEFAULT Bold   '\[\033[01;00m\]'
# BLACK   Normal '\[\033[00;30m\]'
# BLACK   Bold   '\[\033[01;30m\]'
# RED     Normal '\[\033[00;31m\]'
# RED     Bold   '\[\033[01;31m\]'
# GREEN   Normal '\[\033[00;32m\]'
# GREEN   Bold   '\[\033[01;32m\]'
# YELLOW  Normal '\[\033[00;33m\]'
# YELLOW  Bold   '\[\033[01;33m\]'
# BLUE    Normal '\[\033[00;34m\]'
# BLUE    Bold   '\[\033[01;34m\]'
# MAGENTA Normal '\[\033[00;35m\]'
# MAGENTA Bold   '\[\033[01;35m\]'
# CYAN    Normal '\[\033[00;36m\]'
# CYAN    Bold   '\[\033[01;36m\]'
# WHITE   Normal '\[\033[00;37m\]'
# WHITE   Bold   '\[\033[01;37m\]'

function gimp {
  DOCKER_GIMP_REPO="${HOME}/github/docker-gimp"

  if [ -d $DOCKER_GIMP_REPO ] ; then
    cd $DOCKER_GIMP_REPO
    make
  else
    echo "$DOCKER_GIMP_REPO repository does not exist"
  fi
}

function geeqie {
  DOCKER_GEEQIE_REPO="${HOME}/github/docker-geeqie"

  if [ -d $DOCKER_GEEQIE_REPO ] ; then
    cd $DOCKER_GEEQIE_REPO
    make
  else
    echo "$DOCKER_GEEQIE_REPO repository does not exist"
  fi
}

if [ -f ${HOME}/.git-prompt.sh ] ; then
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWSTASHSTATE=1
  source ${HOME}/.git-prompt.sh
  PS1='\[\033[00;35m\]\w\[\033[01;35m\]$(__git_ps1 " μ %s") \[\033[01;37m\]» \[\033[00m\]'
else
  PS1='\[\033[00;36m\]@\[\033[00m\]\h \[\033[01;37m\]\w\[\033[00m\] \$ '
fi

if echo $PATH | grep -v '/opt/bin' > /dev/null ; then
  PATH=$PATH:${HOME}/opt/bin:${HOME}/Library/Python/2.7/bin:${HOME}/opt/go/bin:${HOME}/go/bin
fi

if [ $(uname) == 'Darwin' ] ; then
  export CLICOLOR=1
  export LSCOLORS='exfxcxdxcxegedabagacad'
fi

if [ -f ${HOME}/opt/bin/tree ] ; then
  alias tree='tree -C'
fi

if [ -x ${HOME}/opt/bin/make ] ; then
  alias make='${HOME}/opt/bin/make'
fi
