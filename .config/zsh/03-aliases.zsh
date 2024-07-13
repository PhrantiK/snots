# ┳━┓┳  o┳━┓┓━┓┳━┓┓━┓
# ┃━┫┃  ┃┃━┫┗━┓┣━ ┗━┓
# ┛ ┇┇━┛┇┛ ┇━━┛┻━┛━━┛

(( $+commands[nvim] )) && alias vim="nvim" vimdiff="nvim -d"

# General Aliases
alias sudo="sudo " #Let sudo recognise aliases
alias se="sudoedit"
alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias less="less -R"
alias h="history"
alias mkdir="mkdir -p"
alias md="mkdir"
alias sl="ls"
alias su="sudo su"
alias v="vim"
alias cp="cp -iv"
alias rm="rm -irv"
alias c="clear"
alias ip="ip -color=auto"
alias vv="v ~/.vimrc"
alias bash="SHELL=/bin/bash bash"
# ls
alias ls="ls --color=auto --group-directories-first"
alias l="ls -lh"
alias la="ls -lah"

# tmux
alias t="tmux"
alias tls="t ls"
alias ta="t a -t"
alias tn="t new -t"

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
alias yrm="yadm rm --cached -r"

# git
alias g="git"
alias ga="git add"
alias gp="git push"
alias gl="git pull"
alias gc="git commit --verbose"
alias gca="git commit --verbose --all"
alias gcam="git commit --verbose --all --message"
alias gco="git checkout"
alias gst="git status"
alias gop="git config --get remote.origin.url | sed -e 's/:/\//g'| sed -e 's/ssh\/\/\///g'| sed -e 's/git@/https:\/\//g'"

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

# zfs
alias zl="zfs list"
alias zs="zl -t snapshot"

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

disks() {
	# echo
	function _e() {
		title=$(echo "$1" | sed 's/./& /g')
		echo "
		\033[0;31m╓─────\033[0;35m ${title}
		\033[0;31m╙────────────────────────────────────── ─ ─"
			}
			# loops
			function _l() {
				X=$(printf '\033[0m')
				G=$(printf '\033[0;32m')
				R=$(printf '\033[0;35m')
				C=$(printf '\033[0;36m')
				W=$(printf '\033[0;37m')
				i=0;
				while IFS= read -r line || [[ -n $line ]]; do
					if [[ $i == 0 ]]; then
						echo "${G}${line}${X}"
					else
						if [[ "$line" == *"%"* ]]; then
							percent=$(echo "$line" | awk '{ print $5 }' | sed 's!%!!')
							color=$W
							((percent >= 75)) && color=$C
							((percent >= 90)) && color=$R
							line=$(echo "$line" | sed "s/${percent}%/${color}${percent}%${W}/")
						fi
						echo "${W}${line}${X}" | sed "s/\([─└├┌┐└┘├┤┬┴┼]\)/${R}\1${W}/g; s! \(/.*\)! ${C}\1${W}!g;"
					fi
					i=$((i+1))
				done < <(printf '%s' "$1")
			}
			# outputs
			m=$(lsblk -a | grep -v loop)
			_e "mount.points"
			_l "$m"
			d=$(df -h)
			_e "disk.usage"
			_l "$d"
			s=$(swapon --show)
			_e "swaps"
			_l "$s"
}

# extract all tha thingz
# https://github.com/xvoland/Extract/blob/master/extract.sh
extract() {
	local IFS="$(printf '\n\t')"

	if [ -z "$1" ]; then
		echo "$0 <archive>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso> ..."
		return 1
	else
		for n in "$@"; do
			case "${n%,}" in
				*.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
					tar xvf "$n" ;;
				*.lzma)      unlzma ./"$n"       ;;
				*.bz2)       bunzip2 ./"$n"      ;;
				*.cbr|*.rar) unrar x -ad ./"$n"  ;;
				*.gz)        gunzip ./"$n"       ;;
				*.cbz|*.epub|*.zip) unzip ./"$n" ;;
				*.z)         uncompress ./"$n"   ;;
				*.xz)        unxz ./"$n"         ;;
				*.exe)       cabextract ./"$n"   ;;
				*.cpio)      cpio -id < ./"$n"   ;;
				*.cba|*.ace) unace x ./"$n"      ;;
				*.zpaq)      zpaq x ./"$n"       ;;
				*.arc)       arc e ./"$n"        ;;
				*.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
					7z x ./"$n" ;;
				*.cso)       ciso 0 ./"$n" ./"$n.iso" && \
					extract "$n.iso" && \rm -f "$n" ;;
				*.zlib)      zlib-flate -uncompress < ./"$n" > ./"$n.tmp" && \
					mv ./"$n.tmp" ./"${n%.*zlib}" && rm -f "$n" ;;
				*)
					echo "$0: '$n' - unknown archive method"
					return 1
					;;
			esac
		done
	fi
}
