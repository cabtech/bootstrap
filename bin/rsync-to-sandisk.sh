#!/bin/bash
sandisk=/mnt/hgfs/sandisk
target=${sandisk}/backups/$(hostname)
mkdir -p ${target}
excludes="--exclude=.local --exclude=.cache --exclude=.docker --exclude=.config --exclude=venv/ --exclude=venvs/ --exclude=.git"
rsync -a ${excludes} /home/tim ${target}
exit 0
