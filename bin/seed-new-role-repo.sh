#!/bin/bash
name=${1:-'FAILED'}
seed=ansible-role-ct-terragen

if [[ -d "$name" ]]; then
	rsync -a $seed/.config    $name
	rsync -a $seed/.github    $name
	rsync -a $seed/.gitignore $name
	rsync -a $seed/meta $name
	if [[ ! -e "$name/Makefile" ]]; then
		cat $seed/Makefile | sed "s/${seed}/${name}/g" > $name/Makefile
	fi
	cd $name
	mkdir -p defaults files tasks templates vars
fi
