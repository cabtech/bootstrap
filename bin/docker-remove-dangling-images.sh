#!/bin/bash
iids=$(docker images --filter "dangling=true" -q --no-trunc)
if [[ -n "$iids" ]]; then
	docker rmi $iids
fi
docker images
exit 0
