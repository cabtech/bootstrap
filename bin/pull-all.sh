#!/bin/bash
here=$(pwd)
for kk in ansible-role-*; do
	if [[ -d "$kk" ]]; then
		echo "# --------------------------------"
		echo $kk
		cd $here/$kk
		git pull
		cd $here
	fi
done
exit 0
