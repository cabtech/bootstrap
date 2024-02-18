#!/bin/bash

ss_plugins_dir=/var/lib/terraform/plugins
ss_version="1.4.2"
while getopts p:v: arg; do
	case $arg in
		p) ss_plugins_dir="$OPTARG";;
		v) ss_version="$OPTARG";;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

# --------------------------------

mkdir -p ${ss_plugins_dir}
chmod 777 ${ss_plugins_dir}

if [[ ! -e terraform ]]; then
	echo "Installing Terraform $ss_version"
	wget https://releases.hashicorp.com/terraform/${ss_version}/terraform_${ss_version}_linux_amd64.zip
	unzip terraform_${ss_version}_linux_amd64.zip
	/bin/rm -f terraform_${ss_version}_linux_amd64.zip
else
	echo "terraform already exists"
fi

./terraform -version

exit 0
