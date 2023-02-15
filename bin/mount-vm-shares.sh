#!/bin/bash
dnames='/mnt/hgfs/backups /mnt/hgfs/sandisk /mnt/hgfs/shared'
sudo mkdir -p $dnames
sudo chmod 755 $dnames
# sudo mount -t fuse.vmhgfs-fuse -o allow_other .host:/backups /mnt/hgfs/backups
sudo mount -t fuse.vmhgfs-fuse -o allow_other .host:/sandisk /mnt/hgfs/sandisk
sudo mount -t fuse.vmhgfs-fuse -o allow_other .host:/shared  /mnt/hgfs/shared
exit 0
