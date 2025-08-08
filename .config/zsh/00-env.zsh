export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export PATH="$HOME/.config/bin:$PATH"
export PATH="$HOME/.local/share/nvim-linux-x86_64/bin:$PATH"
export HISTFILE="$HOME/.cache/zsh/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

export EDITOR="vim"
export VISUAL="vim"

# export TERM="xterm-256color"
d=~/.config/zsh/dircolors
test -r $d && eval "$(dircolors $d)"

fpath=($ZDOTDIR $fpath)

(( $+commands[fdfind] )) && fzfind="fdfind" && alias fd="fdfind"
(( $+commands[fd] )) && fzfind="fd"
[ -v fzfind ] && export FZF_DEFAULT_COMMAND="$fzfind --type f --hidden --follow --exclude .git"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height=80% --layout=reverse --no-header --border --margin=2 --padding=1 --pointer=→ --prompt=→ --info=inline:' <--' --cycle --separator=' •' --scrollbar=↕"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS" --color=bg+:8,bg:-1,spinner:3,hl:1 --color=fg:7,header:3,info:5,pointer:3 --color=marker:3,fg+:6,prompt:5,hl+:1"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS" --bind=up:preview-up,down:preview-down,ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up"

# Vim Mode
bindkey -v
export KEYTIMEOUT=1

export MANPAGER="less -R --use-color -Dd+r -Du+b"
# export MANPAGER="vim -c 'set ft=man' -"
