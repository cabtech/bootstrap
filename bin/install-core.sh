#!/bin/bash

base=$( cd $(dirname $0)/.. && pwd -P)

do_core=true
do_verbose=false
while getopts hv arg; do
	case $arg in
		h) echo "no help"; exit 0;;
		v) do_verbose=true;;
		*) echo 'bad arg - bye'; exit 42;;
	esac
done

# --------------------------------

mkdir -p ~/.aws ~/bin/ ~/src ~/tmp
mkdir -p ~/.ssh/cfg.d ~/.ssh/keys
mkdir -p ~/etc ~/etc/bash.d ~/etc/misc ~/etc/pyvirts
mkdir -p ~/work ~/work/pyvirts

chmod 700 ~/.ssh ~/etc

# --------------------------------

if [[ -x /usr/bin/apt ]]; then
	sudo apt update --yes
	sudo apt install --yes apt-transport-https ca-certificates coreutils curl git gnupg2 jq net-tools pip python3 python3-virtualenv vim virtualenv whois wget
	sudo apt install --yes open-vm-tools open-vm-tool-desktop
	sudo apt autoremove --yes
	# awscli
elif [[ -x /usr/bin/dnf ]]; then
	sudo dnf update
	sudo dnf install --yes ca-certificates coreutils curl git gnupg2 jq net-tools pip python3 vim whois wget
	sudo dnf install --yes open-vm-tools open-vm-tool-desktop
	sudo dnf autoremove -y
	# apt-transport-https awscli python3-virtualenv virtualenv
fi

# --------------------------------

echo '#' > ~/etc/bash.d/dummy.sh
for item in ${base}/etc/bash.d/*.sh; do
	stub=$(basename $item)
	if [[ ! -e ~/etc/bash.d/${stub} ]]; then
		/bin/cp ${item} ~/etc/bash.d
	fi
done

grep -q "done # ansible" ~/.bashrc
if (($?==1)); then
	echo '[[ -d ~/etc/bash.d ]] && for ff in ~/etc/bash.d/*.sh; do source $ff; done # ansible' >> ~/.bashrc
	echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi

if [[ ! -r ~/.ssh/cfg.d/000.cfg ]]; then
	echo "StrictHostKeyChecking=false" > ~/.ssh/cfg.d/000.cfg
	chmod 400 ~/.ssh/cfg.d/000.cfg
fi

if [[ ! -r ~/.ssh/config ]]; then
	cat ~/.ssh/cfg.d/*.cfg > ~/.ssh/config
	chmod 400 ~/.ssh/config
fi

if [[ ! -r ~/.vimrc ]]; then
	/bin/cp ${base}/etc/vim/dot_vimrc ~/.vimrc
fi

# --------------------------------

exit 0
