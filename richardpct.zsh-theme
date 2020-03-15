PROMPT_SUCCESS_COLOR=%{$fg_bold[white]%}
PROMPT_FAILURE_COLOR=%{$fg_bold[green]%}
PROMPT_DIR_COLOR=%{$fg[magenta]%}
GIT_BRANCH_COLOR=%{$fg_bold[magenta]%}
GIT_DIRTY_COLOR=%{$fg_bold[magenta]%}
GIT_AHEAD_REMOTE_COLOR=%{$fg_bold[magenta]%}
GIT_BEHIND_REMOTE_COLOR=%{$fg_bold[magenta]%}

PROMPT='%{$PROMPT_DIR_COLOR%}%~%{$reset_color%} $(git_prompt_info)$(git_remote_status)%{$reset_color%}'
PROMPT+="%(?:%{$PROMPT_SUCCESS_COLOR%}» %{$reset_color%}:%{$PROMPT_FAILURE_COLOR%}» %{$reset_color%})"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$GIT_BRANCH_COLOR%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$GIT_DIRTY_COLOR%} ✘ "
ZSH_THEME_GIT_PROMPT_CLEAN=" "
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$GIT_AHEAD_REMOTE_COLOR%}●○ "
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$GIT_BEHIND_REMOTE_COLOR%}○● "
