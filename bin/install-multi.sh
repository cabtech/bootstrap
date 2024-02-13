#!/bin/bash

base=$( cd $(dirname $0)/.. && pwd -P)

do_cloudflare=false
do_docker=false
do_force=false
do_kubernetes=false
do_yubikey=false

while getopts AFdhky arg; do
	case $arg in
		A) do_docker=true;do_kubernetes=true;do_yubikey=true;;
		F) do_force=true;;
		d) do_docker=true;;
		h) echo "no help"; exit 0;;
		k) do_kubernetes=true;;
		y) do_yubikey=true;;
		*) echo 'bad arg - bye'; exit 42;;
	esac
done

# --------------------------------
#	sudo apt install --yes gnupg2 gnupg-agent dirmngr cryptsetup scdaemon pcscd secure-delete hopenpgp-tools yubikey-personalization
#	sudo apt install --yes yubico-piv-tool yubico-piv-tool-devel python3-yubico pam_yubico
#	sudo apt install --yes rustc cargo
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

exit 0
