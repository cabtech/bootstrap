#!/bin/bash

sudo apt install --yes curl

keyring=/usr/share/keyrings/brave-browser-archive-keyring.gpg
sudo curl -fsSLo $keyring https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

if [[ ! -f "${keyring}" ]]; then
	echo "ERROR :: cannot see $keyring"
	exit 4
fi

source_list=/etc/apt/sources.list.d/brave-browser-release.list
if [[ ! -f "${source_list}" ]]; then
echo "deb [signed-by=${keyring} arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee ${source_list}
fi

sudo apt update --yes

sudo apt install --yes brave-browser

exit 0
