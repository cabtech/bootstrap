#!/bin/bash
base=$(cd $(dirname $0) && pwd)
fname=${base}/../etc/repos.cfg

while getopts f: arg; do
	case $arg in
		f) fname="${OPTARG}";;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

cat $fname | while read NAME; do
	git clone git@github.com:cabtech/${NAME}.git
done
exit 0
