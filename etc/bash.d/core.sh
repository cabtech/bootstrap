# MANAGED_BY_ANSIBLE
# shellcheck shell=bash
# --------------------------------

function grenv {
	env | grep ${1:-wibble} | sort
}

function gralias2 {
	alias | sed 's/=/ /' | grep -i "${1:-'wibble'}" | sort
}

function igrenv {
	env | grep -i ${1:-wibble} | sort
}

function gralias {
	alias | grep -i ${1:-wibble} | sort
}

function gralias2 {
	alias | sed 's/=/ /' | grep -i "${1:-'wibble'}" | sort
}

function handy {
	seek=${1:-'.*'}
	grep -i "$seek" ~/etc/handy
}

function sshgrep {
	grep -v '^#' ~/.ssh/config | grep -i -A4 "$1"
}

function hist {
	history | grep -i "${1:-wibble}"
}

function slide {
	cd $(pwd | sed s=/$1=/$2=)
}

function xgrep {
	defpath=$(pwd)
	if [[ -n "$1" ]]; then
		grep -i --exclude-dir=.git --exclude-dir=venv -r "$1" "${2:-$defpath}"
	else
		echo "Usage: xgrep 'string' [path]"
	fi
}

function xpand {
	echo "$1" | tr ':' '\n'
}

# --------------------------------

alias     c='cat'
alias   cls='clear'
alias   dfs='df | grep -v /dev/loop'
alias   dfi='df -iT'
alias   dui='du --inodes --max-depth=1'
alias  dusk='du -sk *'
alias  senv='env | sort'
alias     h='history'
alias     m='less'
alias   psa='/bin/ps -elf'
alias    rm='/bin/rm'
alias     v='vim'
alias    vh='vim handy'
alias    ro='vim -R'

alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias  grep='grep  --color=auto'
alias igrep='grep -i'
alias vgrep='grep -v'
alias     g='grep'

alias myip='curl ipinfo.io'
alias   da='direnv allow'
alias senv='env | sort'
alias    h='history|tail -20'
alias  h50='history|tail -50'
alias h100='history|tail -100'
alias hall='history'
alias    v='vi'
alias   ro='vi -R'

alias chandy='cat ~/etc/handy'
alias vhandy='vi ~/etc/handy'
alias     ch='cat handy'
alias     vh='vi handy'

alias  qbin='cd ~/bin'
alias  qetc='cd ~/etc'
alias  qsrc='cd ~/src'
alias  qtmp='cd ~/tmp'
alias  qvar='cd ~/var'
alias qwork='cd ~/work'

alias up1='cd ..'
alias up2='cd ../..'
alias up3='cd ../../..'
alias up4='cd ../../../..'
alias up5='cd ../../../../..'

alias  _ls='/bin/ls -C --color'
alias   ls='_ls'
alias   l1='_ls -1'
alias   la='_ls -a'
alias   ll='_ls -l'
alias  lla='_ls -la'
alias llrt='_ls -lrt'
alias   LL='_ls -lL'

alias j1='cd ${_m1}'
alias m1='_m1=$(pwd)'
alias j2='cd ${_m2}'
alias m2='_m2=$(pwd)'
alias j3='cd ${_m3}'
alias m3='_m3=$(pwd)'

if [[ -x /usr/bin/fdfind ]]; then
	alias  ff='/usr/bin/fdfind'
	alias ffa='/usr/bin/fdfind --hidden'
fi

# --------------------------------

export HISTCONTROL=ignoreboth
export PATH=${PATH}:${HOME}/bin

set -o vi

#export LC_ALL=C
#export LC_ALL=en_US.UTF-8
export LC_COLLATE=C # treat A and a differently as only right and proper
#export LC_CTYPE=en_US.UTF-8

umask 0022

# --------------------------------
# END
