#!/bin/bash
base=/mnt/hgfs

shares="sandisk shared"
for item in $shares; do
	sudo mkdir -p $base/$item
	sudo chmod 755 $base/$item
	sudo mount -t fuse.vmhgfs-fuse -o allow_other .host:/${item} ${base}/${item}
done
exit 0
