#!/bin/bash

while getopts f: arg; do
	case $arg in
		f) fname="${OPTARG}";;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

if [[ ! -r "$fname" ]]; then
	echo "ERROR :: cannot read $fname"
	exit 4
fi

cat $fname | while read NAME; do
	git clone git@github.com:${NAME}.git
done

exit 0
