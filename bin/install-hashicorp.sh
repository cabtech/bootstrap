#!/bin/bash

hashicorp_apt=/etc/apt/sources.list.d/hashicorp.list
hashicorp_gpg=/usr/share/keyrings/hashicorp-archive-keyring.gpg

# --------------------------------

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

# --------------------------------

exit 0
