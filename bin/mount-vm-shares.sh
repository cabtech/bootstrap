#!/bin/bash

do_verbose=false
ss_base=/mnt/hgfs
ss_shares="sandisk shared"
while getopts b:s:v arg; do
	case $arg in
		s) ss_base="${OPTARG}";;
		s) ss_shares="${OPTARG}";;
		v) do_verbose=false;;
		*) echo "bad arg - bye"; exit 42;;
	esac
done

for item in $ss_shares; do
	$do_verbose && echo "# $item"
	sudo mkdir -p $ss_base/$item
	sudo chmod 755 $ss_base/$item
	sudo mount -t fuse.vmhgfs-fuse -o allow_other .host:/${item} ${ss_base}/${item}
done

df -h
exit 0
