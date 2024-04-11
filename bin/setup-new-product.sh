#!/bin/bash

base=$( cd $(dirname $0)/.. && pwd -P)
ss_acctid=""
ss_cidr=""
ss_domain=""
ss_org=""
ss_product=""
ss_user=timshort
ss_verbose=false

while getopts a:c:d:o:p:u:v arg; do
	case $arg in
		a) ss_acctid="${OPTARG}";;
		c) ss_cidr="${OPTARG}";;
		d) ss_domain="${OPTARG}";;
		o) ss_org="${OPTARG}";;
		p) ss_product="${OPTARG}";;
		u) ss_user="${OPTARG}";;
		v) ss_verbose=true;;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

if [[ -z "${ss_domain}" ]]; then
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

fname=segs.yml
if [[ ! -e "$fname" ]]; then
	$ss_verbose && echo "# Installing vars/$fname"
	/bin/cp $base/etc/${fname} vars/$fname
fi

# --------------------------------

if [[ -n "$ss_org" ]]; then
	mkdir -p ~/etc/${ss_org}
	if [[ -n "$ss_domain" ]]; then
		mkdir -p ~/etc/${ss_org}/${ss_domain}

		if [[ -n "$ss_acctid" ]]; then
			fname=common.yml
			if [[ ! -e "vars/$fname" ]]; then
				$ss_verbose && echo "# Rendering vars/$fname"
				cat $base/template/$fname | sed "s/__ACCTID__/${ss_acctid}/" | sed "s/__DOMAIN__/${ss_domain}/" > vars/$fname
			fi
		fi

		if [[ -n "$ss_product" ]]; then
			mkdir -p ~/etc/${ss_org}/${ss_domain}/${ss_product}
			mkdir -p ~/.ssh/keys/${ss_org}/${ss_domain}/${ss_product}/aws

			prikey=~/.ssh/keys/${ss_org}/${ss_domain}/${ss_product}/aws/id_${ss_user}_${ss_org}_${ss_domain}_${ss_product}_aws
			if [[ ! -e "$prikey" ]]; then
				$ss_verbose && echo "# Generating $prikey"
				ssh-keygen -t ed25519 -a 100 -P "" -f $prikey
				/bin/cp ${prikey}.pub .
			fi

			fname=aws.yml
			if [[ ! -e "vars/$fname" ]]; then
				$ss_verbose && echo "# Rendering vars/$fname"
				cat $base/template/$fname | sed "s/__CIDR__/${ss_cidr}/" | sed "s/__ORG__/${ss_org}/" | sed "s/__DOMAIN__/${ss_domain}/" | sed "s/__PRODUCT__/${ss_product}/" > vars/$fname
			fi

			fname=boot.env
			if [[ ! -e "$fname" ]]; then
				$ss_verbose && echo "# Rendering $fname"
				cat $base/template/$fname | sed "s/__ORG__/${ss_org}/" | sed "s/__DOMAIN__/${ss_domain}/" | sed "s/__PRODUCT__/${ss_product}/" > $fname
			fi

			fname=terragen.yml
			if [[ ! -e "vars/$fname" ]]; then
				$ss_verbose && echo "# Rendering vars/$fname"
				cat $base/template/$fname | sed "s/__ORG__/${ss_org}/" | sed "s/__DOMAIN__/${ss_domain}/" | sed "s/__PRODUCT__/${ss_product}/" > vars/$fname
			fi
		fi
	fi
fi

# --------------------------------

exit 0
