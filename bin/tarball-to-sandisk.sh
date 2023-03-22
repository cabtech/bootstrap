#!/bin/bash

target=/mnt/hgfs/sandisk/backups/$(hostname)
mkdir -p $target

tmpdir=/mnt/hgfs/shared/tmp/$(hostname)
mkdir -p $tmpdir
excludes="--exclude=.local --exclude=.cache --exclude=.docker --exclude=.config --exclude=venv/ --exclude=venvs/ --exclude=.git"
rsync -a ${excludes} /home/tim ${tmpdir}

timestamp=$(date +%Y%m%d)
cd $tmpdir
tar cf ${target}/${timestamp}.tar .

exit 0
