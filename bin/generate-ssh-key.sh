#!/bin/bash

ss_cloud=""
ss_domain=""
ss_org=""
ss_product=""
ss_user=timshort
ss_verbose=false

while getopts c:d:o:p:u:v arg; do
	case $arg in
		c) ss_cloud="${OPTARG}";;
		d) ss_domain="${OPTARG}";;
		o) ss_org="${OPTARG}";;
		p) ss_product="${OPTARG}";;
		u) ss_user="${OPTARG}";;
		v) ss_verbose=true;;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

if [[ -z "${ss_cloud}" ]]; then
	echo "ERROR :: need a domain (-c)"
	exit 4
elif [[ -z "${ss_domain}" ]]; then
	echo "ERROR :: need a domain (-d)"
	exit 4
elif [[ -z "${ss_org}" ]]; then
	echo "ERROR :: need a org (-o)"
	exit 4
elif [[ -z "${ss_product}" ]]; then
	echo "ERROR :: need a product (-p)"
	exit 4
fi

# --------------------------------

slug_path=${ss_org}/${ss_domain}/${ss_product}/${ss_cloud}
mkdir -p ~/.ssh/keys/"${slug_path}"
slug_us=$(echo "$slug_path" | tr '/' '_')
prikey=~/.ssh/keys/${slug_path}/id_${ss_user}_${slug_us}
if [[ ! -e "$prikey" ]]; then
	$ss_verbose && echo "# INFO :: Generating $prikey"
	ssh-keygen -t ed25519 -a 100 -P "" -f "$prikey"
	/bin/cp "${prikey}.pub" .
fi

# --------------------------------

exit 0
