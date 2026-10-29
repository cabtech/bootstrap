#!/bin/bash

# decide whether to restart the SSH agent
restart_agent=false
pgrep ssh-agent > /dev/null
if (($?!=0)); then
	restart_agent=true
fi
if [[ $(date +%A) == "Friday" ]]; then
	restart_agent=true
fi

if $restart_agent; then
	ct-agent.sh
	source ~/etc/bash.d/ssh-agent.sh
	key_base=~/.ssh/keys
	ssh-add -t 1w "$key_base"/issuers/example/id_example
else
	source ~/etc/bash.d/ssh-agent.sh
fi

ssh-add -l
echo ""

aws sso login --sso-session Recommended

exit 0
