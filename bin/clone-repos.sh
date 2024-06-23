#!/bin/bash

ss_verbose=false
while getopts f:v arg; do
	case $arg in
		f) fname="${OPTARG}";;
		v) ss_verbose=true;;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

if [[ ! -r "$fname" ]]; then
	echo "ERROR :: cannot read $fname"
	exit 4
fi

cat $fname | while read NAME; do
	base=$(basename $NAME)
	if [[ ! -d "$base" ]]; then
		git clone git@github.com:${NAME}.git
	elif $ss_verbose; then
		echo "INFO :: $base exists"
	fi
done

exit 0
