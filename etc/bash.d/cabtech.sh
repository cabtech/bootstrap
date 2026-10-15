if [[ -d ~/src/cabtech/ansible-scripts ]]; then
	PATH=${PATH}:~/src/cabtech/ansible-scripts/bin
	PATH=${PATH}:~/src/cabtech/ansible-scripts
fi

if [[ -d ~/work/cabtech ]]; then
	alias    qcs='cd ~/src/cabtech'
	alias     qc='cd ~/work/cabtech'
	alias    qcw='cd ~/work/cabtech'
	alias qroles='cd ~/work/cabtech/roles'
	alias    qtg='cd ~/work/cabtech/roles/ansible-role-ct-terragen'
	alias    qis='cd ~/work/infra-sites'
	alias    qdt='cd ~/work/infra-sites/cabtech/dev/trading'
	alias    qpt='cd ~/work/infra-sites/cabtech/prd/trading'
fi
