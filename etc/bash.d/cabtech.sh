if [[ -d ~/src/cabtech/ansible-scripts ]]; then
    PATH=${PATH}:~/src/cabtech/ansible-scripts/bin
    PATH=${PATH}:~/src/cabtech/ansible-scripts
fi

if [[ -d ~/work/cabtech ]]; then
    alias    qcs='cd ~/src/cabtech'
    alias    qcw='cd ~/work/cabtech'
    alias  qboot='cd ~/work/cabtech/bootstrap'
    alias qroles='cd ~/work/cabtech/roles'
    alias    qtg='cd ~/work/cabtech/roles/ansible-role-ct-terragen'
    alias    qis='cd ~/work/infra-sites'
    alias   qcdt='cd ~/work/infra-sites/cabtech/dev/trading'
    alias   qcpt='cd ~/work/infra-sites/cabtech/prd/trading'
fi

alias localrole='ct-use-local-role.sh ~/work/cabtech/roles -r '
