#!/bin/bash

base=$( cd $(dirname $0)/.. && pwd -P)

# --------------------------------

fname=ansible.cfg
if [[ ! -e "$fname" ]]; then
	echo "Installing $fname"
	cp $base/etc/${fname} .
fi

# --------------------------------

linters="ansible-lint.yml tflint.hcl yamllint"
if [[ ! -d .config ]]; then
	mkdir .config
	for item in $linters; do
		echo "Installing $item"
		cp $base/etc/${item} .config
	done
fi

# --------------------------------
exit 0
