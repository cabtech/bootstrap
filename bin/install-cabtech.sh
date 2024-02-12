#!/bin/bash

base=$(cd $(dirname $0)/.. && pwd)

target=~/src/cabtech
mkdir -p $target
cd $target
for item in $(grep -v '#' $base/etc/cabtech-repos.cfg); do
	if [[ ! -d $target/$item ]]; then
		git clone https://github.com/cabtech/${item}.git
	else
		echo "# skipping https clone of $item"
	fi
done

target=~/work/cabtech
mkdir -p $target
cd $target
for item in $(grep -v '#' $base/etc/cabtech-repos.cfg); do
	if [[ ! -d $target/$item ]]; then
		git clone git@github.com:cabtech/${item}.git
	else
		echo "# skipping git clone $item"
	fi
done

target=~/work/cabtech/roles
mkdir -p $target
cd $target
for item in $(grep -v '#' $base/etc/cabtech-roles.cfg); do
	if [[ ! -d $target/$item ]]; then
		git clone git@github.com:cabtech/${item}.git
	else
		echo "# skipping git clone $item"
	fi
done

mkdir -p ~/etc/bash.d
grep -q "done # ansible" ~/.bashrc
if (($?==0)); then
	echo "[[ -d ~/etc/bash.d ]] && for ff in ~/etc/bash.d/*.sh; do source $ff; done # ansible" >> ~/.bashrc
	echo "#" > ~/etc/bash.d/remove-after-adding-proper-script.sh
else
	echo "# skipping bash.d line in .bashrc"
fi

~/src/cabtech/ansible-scripts/ct-mkssh.sh -x

exit 0
