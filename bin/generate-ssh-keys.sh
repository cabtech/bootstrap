#!/bin/bash

ss_accts=""
ss_cloud="aws"
ss_org=""
ss_user="timshort"

while getopts a:c:o:u: arg; do
	case $arg in
		a) ss_accts=${OPTARG};;
		c) ss_cloud=${OPTARG};;
		o) ss_org=${OPTARG};;
		u) ss_user=${OPTARG};;
		*) echo "bad args - bye"; exit 42;;
	esac
done

if [[ -z "$ss_accts" ]]; then
	echo "ERROR :: need CSV string of accts (-a)"
	exit 4
else
	accts=$(echo $ss_accts | tr "," " ")
fi

if [[ -z "$ss_cloud" ]]; then
	echo "ERROR :: need cloud (-c)"
	exit 4
fi

if [[ -z "$ss_org" ]]; then
	echo "ERROR :: need org (-o)"
	exit 4
fi

if [[ -z "$ss_user" ]]; then
	echo "ERROR :: need user (-u)"
	exit 4
fi

for acct in $accts; do
	mkdir -p ~/.ssh/keys/${ss_org}/${ss_cloud}/${acct}
	fname=~/.ssh/keys/${ss_org}/${ss_cloud}/${acct}/id_${ss_user}_${ss_org}_${ss_cloud}_${acct}
	if [[ ! -f "$fname" ]]; then
		ssh-keygen -t ed25519 -a 100 -P '' -f $fname -C "id_${ss_user}_${ss_org}_${ss_cloud}_${acct}"
	else
		echo "$fname exists"
	fi
done

cat ~/.ssh/keys/${ss_org}/${ss_cloud}/*/id_*.pub

exit 0
