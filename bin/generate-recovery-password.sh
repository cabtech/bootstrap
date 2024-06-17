#!/bin/bash
raw=$(uuidgen | tr -d '-' | cut -c -16)
echo $raw
hashed=$(echo $raw | mkpasswd --stdin --method=sha-512)
# echo $hashed
cat << ENDCAT
        "recovery_checksum": "${hashed}",
        "recovery_username": "recovery",
ENDCAT
exit 0
