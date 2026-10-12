#!/bin/bash

ss_domain="cabtech-github.com"
ss_fname="repos.cfg"
ss_verbose=false

while getopts d:f:v arg; do
	case $arg in
		d) ss_domain="${OPTARG}";;
		f) ss_fname="${OPTARG}";;
		v) ss_verbose=true;;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

if [[ ! -r "$ss_fname" ]]; then
	echo "ERROR :: cannot read $ss_fname"
	exit 4
fi

grep -v '#' "$ss_fname" | tr "," " " | while read -r NAME DOMAIN; do
	if [[ -z "$DOMAIN" ]]; then
		DOMAIN="${ss_domain}"
	fi
	base=$(basename "$NAME")
	if [[ ! -d "$base" ]]; then
		git clone git@"${DOMAIN}":"${NAME}".git
	elif $ss_verbose; then
		echo "INFO :: $base exists"
	fi
done

exit 0
