export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export PATH="$HOME/.config/bin:$PATH"
export HISTFILE="$HOME/.cache/zsh/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

export EDITOR="vim"
export VISUAL="vim"

d=~/.config/zsh/dircolors
test -r $d && eval "$(dircolors $d)"

fpath=($ZDOTDIR $fpath)

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height=80% --layout=reverse  --border --margin=2 --padding=2"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

# export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS" --color=bg+:${color_grey5},bg:${color_bg},spinner:${color_yellow},hl:${color_red} --color=fg:${color_fg},header:${color_red},info:${color_pink},pointer:${color_yellow} --color=marker:${color_yellow},fg+:${color_fg2},prompt:${color_magenta},hl+:${color_red}"

# Vim Mode
bindkey -v
export KEYTIMEOUT=1
source ~/.config/zsh/cursor_mode

export MANPAGER="less -R --use-color -Dd+r -Du+b"
# export MANPAGER="vim -c 'set ft=man' -"

