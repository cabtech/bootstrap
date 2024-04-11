#!/bin/bash

ss_fname=""
ss_method=git
ss_owner=cabtech
while getopts f:m:o: arg; do
	case $arg in
		f) ss_fname="${OPTARG}";;
		m) ss_method="${OPTARG}";;
		o) ss_owner="${OPTARG}";;
		*) echo "ERROR :: bad arg - bye"; exit 42;;
	esac
done

basegit="git@github.com:${ss_owner}"
basehttps="https://github.com/${ss_owner}"

if [[ ! -r "$ss_fname" ]]; then
	echo "ERROR :: cannot read $ss_fname"
	exit 4
else
	repos=$(cat $ss_fname)
fi

if [[ "$ss_method" == "git" ]]; then
	for repo in $repos; do
		if [[ ! -d "$repo" ]]; then
			git clone ${basegit}/${repo}.git
		else
			echo "$repo exists"
		fi
	done
elif [[ "$ss_method" == "https" ]]; then
	for repo in $repos; do
		if [[ ! -d "$repo" ]]; then
			git clone ${basehttps}/${repo}.git
		else
			echo "$repo exists"
		fi
	done
fi

exit 0
