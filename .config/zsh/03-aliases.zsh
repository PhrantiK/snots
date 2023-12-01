# ┳━┓┳  o┳━┓┓━┓┳━┓┓━┓
# ┃━┫┃  ┃┃━┫┗━┓┣━ ┗━┓
# ┛ ┇┇━┛┇┛ ┇━━┛┻━┛━━┛

command -v nvim >/dev/null && alias vim="nvim" vimdiff="nvim -d" # Alias neovim as vim if present.

# General Aliases
alias sudo="sudo " #Let sudo recognise aliases
alias se="sudo -E vim"
alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias less="less -R"
alias h="history"
alias mkdir="mkdir -p"
alias sl="ls"
alias su="sudo su"
alias v="vim"
alias cp="cp -iv"
alias rm="rm -irv"
alias c="clear"
alias ip="ip -color=auto"

# ls
alias ls="ls --color=auto --group-directories-first"
alias l="ls -lh"
alias la="ls -lah"

# tmux
alias t="tmux"
alias tls="t ls"
alias ta="t a -t"
alias tn="t new -t"

alias disks='echo "╓───── m o u n t . p o i n t s"; \
             echo "╙────────────────────────────────────── ─ ─ "; \
             lsblk -a; echo ""; \
             echo "╓───── d i s k . u s a g e"; \
             echo "╙────────────────────────────────────── ─ ─ "; \
             df -h;'

# void
alias xg="xbps-query -l | grep"
alias xs="fuzzypkg"
alias xu="sudo xbps-install -Su"
alias xr="sudo xbps-remove -R"
alias xcl="sudo xbps-remove -Oo"

# yadm
alias yst="yadm status"
alias ya="yadm add"
alias yd="yadm diff"
alias yds="yadm diff --staged"
alias yc="yadm commit"
alias ycam="yadm commit -a -m"
alias yp="yadm push"

# git
alias g="git"
alias ga="git add"
alias gc="git commit --verbose"
alias gca="git commit --verbose --all"
alias gcam="git commit --verbose --all --message"
alias gco="git checkout"
alias gst="git status"

# compose
alias dcb="docker compose build"
alias dce="docker compose exec"
alias dcps="docker compose ps"
alias dcstop="docker compose stop"
alias dcupd="docker compose up -d"
alias dcl="docker compose logs"
alias dclf="docker compose logs -f"
alias dcpull="docker compose pull"
alias dck="docker compose kill"

# ┳━┓┳ ┓┏┓┓┏━┓┏┓┓o┏━┓┏┓┓┓━┓
# ┣━ ┃ ┃┃┃┃┃   ┃ ┃┃ ┃┃┃┃┗━┓
# ┇  ┇━┛┇┗┛┗━┛ ┇ ┇┛━┛┇┗┛━━┛

tmm() {
	X=$#
	[[ $X -eq 0 ]] || X=X
	tmux new-session -A -s $X
}

cht() { curl -s cheat.sh/"$@" | cat }

dt() { du -a ~/.config/* | awk '{print $2}' | fzf | xargs -r $EDITOR ;}

vf() { fzf | xargs -r -I % $EDITOR % ;}

exy() {
    touch $1 && chmod +x $1 && v +'norm i#!/bin/sh' +'norm 2o' -- $1
}

# Disk usage
du1() { du -h --max-depth=1 "$@" | sort -k 1,1hr -k 2,2f; }

apt-history() {
  case "$1" in
    install)
      zgrep --no-filename 'install ' $(ls -rt /var/log/dpkg*)
      ;;
    upgrade|remove)
      zgrep --no-filename $1 $(ls -rt /var/log/dpkg*)
      ;;
    rollback)
      zgrep --no-filename upgrade $(ls -rt /var/log/dpkg*) | \
        grep "$2" -A10000000 | \
        grep "$3" -B10000000 | \
        awk '{print $4"="$5}'
      ;;
    list)
      zgrep --no-filename '' $(ls -rt /var/log/dpkg*)
      ;;
    *)
      echo "Parameters:"
      echo " install - Lists all packages that have been installed."
      echo " upgrade - Lists all packages that have been upgraded."
      echo " remove - Lists all packages that have been removed."
      echo " rollback - Lists rollback information."
      echo " list - Lists all contains of dpkg logs."
      ;;
  esac
}
