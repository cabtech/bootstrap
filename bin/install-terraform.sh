#!/bin/bash

ss_version="1.4.2"
while getopts v: arg; do
	case $arg in
		v) ss_version="$OPTARG";;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

# --------------------------------

if [[ ! -e terraform ]]; then
	echo "Installing Terraform $ss_version"
	wget https://releases.hashicorp.com/terraform/${ss_version}/terraform_${ss_version}_linux_amd64.zip
	unzip terraform_${ss_version}_linux_amd64.zip
	/bin/rm -f terraform_${ss_version}_linux_amd64.zip
else
	echo "terraform already exists"
	./terraform -version
fi

exit 0
