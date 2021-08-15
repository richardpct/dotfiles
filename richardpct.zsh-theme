function prompt_docker {
  if grep docker /proc/1/cgroup > /dev/null 2>&1; then
    printf '🐳 '
  fi
}

function remote_host {
  if [ -v SSH_TTY ]; then
    printf @$(hostname)
  fi
}

PROMPT_SUCCESS_COLOR=%{$fg_bold[white]%}
PROMPT_FAILURE_COLOR=%{$fg_bold[green]%}
PROMPT_DIR_COLOR=%{$fg[magenta]%}
PROMPT_REMOTEHOST_COLOR=%{$fg[white]%}
GIT_BRANCH_COLOR=%{$fg_bold[magenta]%}
GIT_DIRTY_COLOR=%{$fg_bold[magenta]%}
GIT_AHEAD_REMOTE_COLOR=%{$fg_bold[magenta]%}
GIT_BEHIND_REMOTE_COLOR=%{$fg_bold[magenta]%}

PROMPT='$(prompt_docker)%{$PROMPT_REMOTEHOST_COLOR%}$(remote_host)%{$PROMPT_DIR_COLOR%} %~%{$reset_color%} $(git_prompt_info)$(git_remote_status)%{$reset_color%}'
PROMPT+="%(?:%{$PROMPT_SUCCESS_COLOR%}» %{$reset_color%}:%{$PROMPT_FAILURE_COLOR%}» %{$reset_color%})"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$GIT_BRANCH_COLOR%}ᚶ "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$GIT_DIRTY_COLOR%} ✘ "
ZSH_THEME_GIT_PROMPT_CLEAN=" "
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$GIT_AHEAD_REMOTE_COLOR%}●○ "
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$GIT_BEHIND_REMOTE_COLOR%}○● "
