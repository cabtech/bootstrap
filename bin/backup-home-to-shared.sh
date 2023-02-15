#!/bin/bash
cd /home
rsync --progress -a --no-links --info="skip0" \
--exclude=".cache" \
--exclude=".cargo" \
--exclude=".git" \
--exclude=".java" \
--exclude=".local" \
--exclude=".npm" \
--exclude=".nvm" \
--exclude=".rustup" \
--exclude=".terraform" \
--exclude="site-packages" \
--exclude="snap" \
--exclude="venvs" \
tim /mnt/hgfs/shared/backups
exit 0

