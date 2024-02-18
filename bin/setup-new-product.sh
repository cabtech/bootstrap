#!/bin/bash

base=$( cd $(dirname $0)/.. && pwd -P)
ss_verbose=false

while getopts v arg; do
	case $arg in
		v) ss_verbose=true;;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

# --------------------------------

fname=ansible.cfg
if [[ ! -e "$fname" ]]; then
	$ss_verbose && echo "# Installing $fname"
	/bin/cp $base/etc/${fname} .
fi

if [[ ! -d .config ]]; then
	$ss_verbose && echo "# Installing config for linters"
	mkdir -p .config
	rsync -a $base/etc/linters/ .config
fi

fname=requirements.yml
if [[ ! -e "$fname" ]]; then
	$ss_verbose && echo "# Installing $fname"
	/bin/cp $base/etc/${fname} .
fi

fname=Makefile
if [[ ! -e "$fname" ]]; then
	$ss_verbose && echo "# Installing $fname"
	/bin/cp $base/etc/${fname} .
fi

# --------------------------------

exit 0
