#!/bin/bash

base=$( cd $(dirname $0)/.. && pwd -P)

do_cloudflare=false
do_core=false
do_docker=false
do_force=false
do_hashicorp=false
do_kubernetes=false
do_yubikey=false

while getopts AFacdhky arg; do
	case $arg in
		A) do_core=true;do_docker=true;do_hashicorp=true;do_kubernetes=true;do_yubikey=true;;
		F) do_force=true;;
		a) do_hashicorp=true;;
		c) do_core=true;;
		d) do_docker=true;;
		h) echo "no help"; exit 0;;
		k) do_kubernetes=true;;
		y) do_yubikey=true;;
		*) echo 'bad arg - bye'; exit 42;;
	esac
done

# --------------------------------

if $do_core; then
	mkdir -p ~/.aws ~/bin/ ~/etc ~/src ~/tmp ~/work
	mkdir -p ~/.ssh/cfg.d ~/etc/bash.d ~/etc/misc
	chmod 700 ~/.ssh ~/etc 

	sudo apt update --yes
	sudo apt install --yes apt-transport-https awscli ca-certificates coreutils curl git gnupg2 jq net-tools oathtool open-vm-tools pip python3 python3-virtualenv vim virtualenv whois wget
#	sudo apt install --yes gnupg2 gnupg-agent dirmngr cryptsetup scdaemon pcscd secure-delete hopenpgp-tools yubikey-personalization
#	sudo apt install --yes yubico-piv-tool yubico-piv-tool-devel python3-yubico pam_yubico
	sudo apt install --yes rustc cargo

	if $do_force; then
		/bin/cp ${base}/etc/bash.d/*.sh ~/etc/bash.d
	fi

	grep -q BOOTSTRAP ~/.bashrc
	if (($?!=0)); then
		echo 'for kk in ~/etc/bash.d/*.sh; do source $kk; done # BOOTSTRAP' >> ~/.bashrc
		echo "#" > ~/etc/bash.d/remove.sh
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

	if [[ ! -d ~/.vim/ftplugin ]]; then
		mkdir -p ~/.vim/ftplugin
		/bin/cp ${base}/etc/vim/ftplugin/* ~/.vim/ftplugin
	fi
fi

# --------------------------------

if $do_docker; then
	docker_apt=/etc/apt/sources.list.d/docker.list
	docker_gpg=/etc/apt/keyrings/docker.gpg

	if [[ ! -r "${docker_apt}" ]]; then
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o ${docker_gpg}
		echo "deb [arch=$(dpkg --print-architecture) signed-by=${docker_gpg}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee ${docker_apt} > /dev/null
		sudo apt-get update
	fi
	sudo apt-get install --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin
	sudo usermod -a -G docker $USER
fi

# --------------------------------

if $do_hashicorp; then
	hashicorp_apt=/etc/apt/sources.list.d/hashicorp.list
	hashicorp_gpg=/usr/share/keyrings/hashicorp-archive-keyring.gpg

	if [[ ! -f ${hashicorp_gpg} ]]; then
		wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee $hashicorp_gpg > /dev/null
	fi
	if [[ ! -f ${hashicorp_apt} ]]; then
		echo "deb [signed-by=$hashicorp_gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee $hashicorp_apt
		sudo apt update
	fi
 	sudo apt install consul nomad terraform vault
	sudo mkdir -p /var/lib/terraform/plugins
	sudo chmod 755 /var/lib/terraform
	sudo chmod 777 /var/lib/terraform/plugins

	echo "# MANUAL create ~/.terraformrc"
fi

# --------------------------------

if $do_kubernetes; then
	kubernetes_apt=/etc/apt/sources.list.d/kubernetes.list
	kubernetes_gpg=/usr/share/keyrings/kubernetes-archive-keyring.gpg

	if [[ ! -f ${kubernetes_gpg} ]]; then
		sudo curl -fsSLo ${kubernetes_gpg} https://packages.cloud.google.com/apt/doc/apt-key.gpg
	fi

	if [[ ! -f ${kubernetes_apt} ]]; then
		echo "deb [signed-by=${kubernetes_gpg}] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee ${kubernetes_apt}
		sudo apt update
	fi
	sudo apt install kubectl
fi

# --------------------------------

if $do_yubikey; then
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 32CBA1A9
	sudo add-apt-repository ppa:yubico/stable
	sudo apt update
	sudo apt install yubikey-manager
	sudo apt install libfido2-1 libfido2-dev libfido2-doc fido2-tools
	#sudo apt install yubikey-personalization-gui
	#sudo systemctl restart pcscd
	#sudo pkill  scdaemon
fi

# --------------------------------

if $do_cloudflare; then
	mkdir ~/.cloudflare
	chmod 700 ~/.cloudflare
fi

# --------------------------------

sudo apt autoremove --yes

# --------------------------------

exit 0
