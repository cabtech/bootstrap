# --------------------------------

function grenv {
	env | grep ${1:-wibble}
}

function igrenv {
	env | grep -i ${1:-wibble}
}

function gralias {
	env | grep -i ${1:-wibble}
}

function handy {
	grep ${1:-wibble} ~/etc/misc/handy
}

function sshgrep {
	grep -A4 -i ${1:-wibble} ~/.ssh/config
}

function hist {
	history | grep -i "${1:-wibble}"
}

function slide {
	cd $(pwd | sed s=/$1=/$2=)
}

# --------------------------------

alias senv='env | sort'
alias   mk='make'

alias    h='history|tail -20'
alias  h50='history|tail -50'
alias h100='history|tail -100'
alias hall='history'

alias      v='vi'
alias     ro='vi -R'

alias chandy='cat ~/etc/misc/handy'
alias vhandy='vi ~/etc/misc/handy'
alias     ch='cat handy'
alias     vh='vi handy'

alias  qbin='cd ~/bin'
alias  qetc='cd ~/etc'
alias  qsrc='cd ~/src'
alias  qtmp='cd ~/tmp'
alias qwork='cd ~/work'

alias up1='cd ..'
alias up2='cd ../..'
alias up3='cd ../../..'
alias up4='cd ../../../..'

alias  _ls='/bin/ls --color'
alias   ls='_ls'
alias   l1='_ls -1'
alias   ll='_ls -l'
alias llrt='_ls -lrt'

alias j1="cd ${_m1}"
alias m1='_m1=$(pwd)'
alias j2="cd ${_m2}"
alias m2='_m2=$(pwd)'
alias j3="cd ${_m3}"
alias m3='_m3=$(pwd)'

if [[ -x /opt/sublime_text/sublime_text ]]; then
alias st='/opt/sublime_text/sublime_text'
fi

# --------------------------------

export HISTCONTROL=ignoreboth
export PATH=${PATH}:~/bin
export PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\] "

#export LC_ALL=C
export LC_COLLATE=C
#export LC_CTYPE=en_US.UTF-8
#export LC_ALL=en_US.UTF-8

umask 0022

# --------------------------------
