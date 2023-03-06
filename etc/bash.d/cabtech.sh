alias qcs='cd ~/src/cabtech'
alias qcw='cd ~/work/cabtech'
alias qroles='cd ~/work/cabtech/roles'

if [[ -d ~/src/cabtech/ansible-scripts ]]; then
	export PATH=${PATH}:~/src/cabtech/ansible-scripts
fi

if [[ -d ~/src/cabtech/terraform-scripts ]]; then
	export PATH=${PATH}:~/src/cabtech/terraform-scripts
fi
