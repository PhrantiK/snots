#      __               __
#     / /_  ____ ______/ /_
#    / __ \/ __ `/ ___/ __ \
#   / /_/ / /_/ (__  ) / / /
#  /_.___/\__,_/____/_/ /_/
#

[[ $- == *i* ]] || return  # non-interactive shell

HISTCONTROL=ignoreboth
HISTSIZE=1000000000
HISTFILESIZE=1000000000
HISTFILE="$HOME"/.bash_history

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

export LS_COLORS='rs=0:no=00:mi=00:mh=00:ln=01;36:or=01;31:di=01;34:ow=04;01;34:st=34:tw=04;34:'
LS_COLORS+='pi=01;33:so=01;33:do=01;33:bd=01;33:cd=01;33:su=01;35:sg=01;35:ca=01;35:ex=01;32:'

#export TERM='tmux-256color'

export EDITOR='vi'
export LS_OPTIONS='--color=auto --group-directories-first'

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias la='ls $LS_OPTIONS -lA'
alias l='ls $LS_OPTIONS -lh'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias c='clear'
alias v='${EDITOR} '

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi

PS1='\n\[\033[0;90m\]\u@\h\[\033[00m\] '         # user@host
PS1+='\[\033[0;34m\]\w\[\033[00m\]'              # blue current working directory
PS1+='\n\[\033[01;$((31+!$?))m\]->\[\033[00m\] '  # green/red (success/error) $/# (normal/root)

eval "$(dircolors)"

PROMPT_DIRTRIM=3
