#!/bin/bash

do_rsync=true
do_sandisk=true
while getopts RSrs arg; do
	case $arg in
		R) do_rsync=false;;
		S) do_sandisk=false;;
		r) do_rsync=true;;
		s) do_sandisk=true;;
		*) echo "bad arg"; exit 42;;
	esac
done

machine=$(hostname)
sandisk_base=/mnt/hgfs/sandisk
sandisk_dir=${sandisk_base}/backups/${machine}
shared_base=/mnt/hgfs/shared
shared_dir=${shared_base}/backups/${machine}
timestamp=$(date +%Y%m%d)
rsync_excludes="--exclude=product/disruptor/ --exclude=product/world/ --exclude=product/research/ --exclude=.local --exclude=.cache --exclude=.docker --exclude=.config --exclude=venv/ --exclude=venvs/ --exclude=.git"

mkdir -p $shared_dir
mkdir -p $sandisk_dir

if $do_rsync; then
	echo "Running rsync"
	rsync -a --no-links ${rsync_excludes} /home/tim ${shared_dir}
fi

if $do_sandisk; then
	if [[ -d "$shared_dir" ]]; then
		echo "Creating tarball"
		cd $shared_dir
		tmptar=${shared_base}/${machine}.tar
		tar cf ${tmptar} .

		echo "Moving tarball"
		/bin/cp -p $tmptar ${sandisk_dir}/${timestamp}.tar
		/bin/rm -f $tmptar
	fi
fi

exit 0
