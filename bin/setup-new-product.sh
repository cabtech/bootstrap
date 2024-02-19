#!/bin/bash

base=$( cd $(dirname $0)/.. && pwd -P)
ss_acctid=""
ss_domain=""
ss_org=""
ss_product=""
ss_verbose=false

while getopts a:d:o:p:v arg; do
	case $arg in
		a) ss_acctid="${OPTARG}";;
		d) ss_domain="${OPTARG}";;
		o) ss_org="${OPTARG}";;
		p) ss_product="${OPTARG}";;
		v) ss_verbose=true;;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

# --------------------------------

if [[ ! -d .config ]]; then
	$ss_verbose && echo "# Installing config for linters"
	mkdir -p .config
	rsync -a $base/etc/linters/ .config
fi

fname=Makefile
if [[ ! -e "$fname" ]]; then
	$ss_verbose && echo "# Installing $fname"
	/bin/cp $base/etc/${fname} .
fi

fname=ansible.cfg
if [[ ! -e "$fname" ]]; then
	$ss_verbose && echo "# Installing $fname"
	/bin/cp $base/etc/${fname} .
	chmod 644 $fname
fi

fname=ansible.env
if [[ ! -e "$fname" ]]; then
	$ss_verbose && echo "# Installing $fname"
	/bin/cp $base/etc/${fname} .
fi
grep -q ORG $fname
if (($?==0)); then
	echo "Remember to update $fname"
fi

fname=dummy.tf
if [[ ! -e "$fname" ]]; then
	$ss_verbose && echo "# touched $fname"
	touch $fname
fi

fname=requirements.yml
if [[ ! -e "$fname" ]]; then
	$ss_verbose && echo "# Installing $fname"
	/bin/cp $base/etc/${fname} .
fi

# --------------------------------

if [[ -n "$ss_org" ]]; then
	mkdir -p ~/etc/${ss_org}
	if [[ -n "$ss_domain" ]]; then
		mkdir -p ~/etc/${ss_org}/${ss_domain}

		if [[ -n "$ss_acctid" ]]; then
			fname=common.yml
			if [[ ! -e "vars/$fname" ]]; then
				$ss_verbose && echo "# Rendering $fname"
				cat $base/template/$fname | sed "s/__ACCTID__/${ss_acctid}" | sed "s/__DOMAIN__/${ss_domain}/" > vars/$fname
			fi
		fi

		if [[ -n "$ss_product" ]]; then
			mkdir -p ~/etc/${ss_org}/${ss_domain}/${ss_product}

			fname=boot.env
			if [[ ! -e "$fname" ]]; then
				$ss_verbose && echo "# Rendering $fname"
				cat $base/template/$fname | sed "s/__ORG__/${ss_org}/" | sed "s/__DOMAIN__/${ss_domain}/" | sed "s/__PRODUCT__/${ss_product}/" > $fname
			fi

			fname=terragen.yml
			if [[ ! -e "vars/$fname" ]]; then
				$ss_verbose && echo "# Rendering $fname"
				cat $base/template/$fname | sed "s/__ORG__/${ss_org}/" | sed "s/__DOMAIN__/${ss_domain}/" | sed "s/__PRODUCT__/${ss_product}/" > vars/$fname
			fi
		fi
	fi
fi

# --------------------------------

exit 0
