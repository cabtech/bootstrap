#!/bin/bash

prog=$(basename "$0")

action="status"
while getopts a:dpw arg; do
	case $arg in
		a) action="${OPTARG}";;
		d) action="diff";;
		p) action="pull";;
		w) action="diff -w";;
		*) echo "$prog :: ERROR :: bad arg"; exit 42;;
	esac
done

here=$(pwd)
for kk in *; do
	if [[ -d "$here/$kk" ]]; then
		if [[ -d "$here/$kk/.git" ]]; then
			cd "$here/$kk" || exit 4
			echo '# --------------------------------'
			pwd
			git "$action"
		fi
	fi
done

exit 0
