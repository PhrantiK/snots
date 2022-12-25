# ┳━┓┳  o┳━┓┓━┓┳━┓┓━┓
# ┃━┫┃  ┃┃━┫┗━┓┣━ ┗━┓
# ┛ ┇┇━┛┇┛ ┇━━┛┻━┛━━┛

command -v nvim >/dev/null && alias vim="nvim" vimdiff="nvim -d" # Alias neovim as vim if present.

# General Aliases
alias sudo="sudo " #Let sudo recognise aliases
alias _="sudo "
alias se="sudo -E vim"
alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias less="less -R"
alias h="history"
alias mkdir="mkdir -p"
alias sl="ls"
alias su="sudo su"
alias v="vim"
alias zr="source $ZDOTDIR/.zshrc"
alias cp="cp -iv"
alias rm="rm -irv"
alias c="clear"
alias ip="ip -color=auto"

# ls
alias ls="ls --color=auto --group-directories-first"
alias l="ls -lh"
alias la="ls -lah"

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
alias yp="yadm push"

# ┳━┓┳ ┓┏┓┓┏━┓┏┓┓o┏━┓┏┓┓┓━┓
# ┣━ ┃ ┃┃┃┃┃   ┃ ┃┃ ┃┃┃┃┗━┓
# ┇  ┇━┛┇┗┛┗━┛ ┇ ┇┛━┛┇┗┛━━┛

tmm() {
	X=$#
	[[ $X -eq 0 ]] || X=X
	tmux new-session -A -s $X
}

cheat() { curl -s cheat.sh/"$@" | cat }

dt() { du -a ~/.config/* | awk '{print $2}' | fzf | xargs -r $EDITOR ;}

vf() { fzf | xargs -r -I % $EDITOR % ;}

# Disk usage
du1() { gdu -h --max-depth=1 "$@" | sort -k 1,1hr -k 2,2f; }

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
