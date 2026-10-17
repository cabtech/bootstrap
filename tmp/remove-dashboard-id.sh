#!/bin/bash
for fname in dashboards/*.json; do
	echo $fname
	cat $fname | jq 'del(.dashboard.id)' > qq
	mv qq $fname
done
/bin/ls -l dashboards
exit 0
