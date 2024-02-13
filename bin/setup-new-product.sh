#!/bin/bash

base=$( cd $(dirname $0)/.. && pwd -P)

# --------------------------------

fname=ansible.cfg
if [[ ! -e "$fname" ]]; then
	echo "# Installing $fname"
	cp $base/etc/${fname} .
fi

if [[ ! -d .config ]]; then
	echo "# Installing config for linters"
	mkdir -p .config
	rsync -a $base/etc/linters/ .config
fi

fname=requirements.yml
if [[ ! -e "$fname" ]]; then
	echo "# Installing $fname"
    cp $base/etc/${fname} .
fi

# --------------------------------
exit 0
