#!/bin/bash

action="status"
while getopts a:p arg; do
	case $arg in
		a) action="${OPTARG}";;
		p) action="pull";;
		*) echo "$prog :: ERROR :: bad arg"; exit 42;;
	esac
done

here=$(pwd)
for kk in *; do
	if [[ -d "$here/$kk" ]]; then
		if [[ -d "$here/$kk/.git" ]]; then
			cd $here/$kk
			echo '# --------------------------------'
			pwd
			git $action
		fi
	fi
done

exit 0
