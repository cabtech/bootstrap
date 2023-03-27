#!/bin/bash

target=/mnt/hgfs/sandisk/backups/$(hostname)
mkdir -p $target

tmpdir=/mnt/hgfs/shared/tmp/$(hostname)
mkdir -p $tmpdir
excludes="--exclude=.cache --exclude=.config --exclude=.docker --exclude=.git --exclude=.local --exclude=.mozilla --exclude=venv/ --exclude=venvs/"
rsync -a ${excludes} /home/tim ${tmpdir}

timestamp=$(date +%Y%m%d)
cd $tmpdir
tar cf ${target}/${timestamp}.tar .

exit 0
