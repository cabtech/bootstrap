#!/bin/bash

do_rsync=false
do_tarball=false
ss_workdir=/mnt/hgfs/shared/var
while getopts rtw: arg; do
	case $arg in
		r) do_rsync=true;;
		t) do_tarball=true;;
		w) ss_workdir="$OPTARG";;
		*) echo "bad arg - bye"; exit 42;;
	esac
done

sandisk=/mnt/hgfs/sandisk
backups=${sandisk}/backups/work
fifthrow=${sandisk}/orgs/fifthrow

# --------------------------------

if [[ ! -d "$ss_workdir" ]]; then
	echo "Need to mount $dest"
	exit 4
elif [[ ! -d "$sandisk" ]]; then
	echo "Need to mount $sandisk"
	exit 8
else
	if $do_rsync; then
		echo "Running rsync"
		mkdir -p ${fifthrow}
		if [[ -d /home/tim/work/fifthrow ]]; then
			rsync --exclude=.git -rptgoD /home/tim/work/fifthrow/ ${fifthrow}  # -a but without -l
		fi
		if [[ -d /home/tim/work/frt/gitlab/devops ]]; then
			rsync --exclude=.git -a /home/tim/work/frt/gitlab/devops ${fifthrow}
		fi
	fi

	if $do_tarball; then
		mkdir -p $backups
		echo "Making tarball"
		fname=$(hostname).$(date +%Y%m%d_%H).tgz
		cd /home
		tar --exclude=".local" --exclude=.cache --exclude=.docker --exclude=.config/chromium --exclude=venv/ --exclude=venvs/ --exclude=.git/ -zcf ${ss_workdir}/${fname} tim
		# pswd=$(cat ~/etc/misc/backups.txt)
		# openssl enc -k $pswd '-aes-256-cbc' -salt -in $target -out ${target}.enc
		# cp ${target}.enc $onedrive
		echo "Transferring tarball"
		if [[ -r ${ss_workdir}/${fname} ]]; then
			/bin/cp ${ss_workdir}/${fname} ${backups}
		else
			echo "Could not read ${ss_workdir}/${fname}"
		fi
	fi
fi

# --------------------------------

exit 0
