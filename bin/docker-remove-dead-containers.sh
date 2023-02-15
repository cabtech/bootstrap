#!/bin/bash
cids=$(docker ps -aq --filter status=exited)
for kk in $cids; do
	docker rm $kk
done
exit 0
