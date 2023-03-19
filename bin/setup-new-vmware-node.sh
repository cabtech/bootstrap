#!/bin/bash
sudo apt update --yes
sudo apt install openssh-server --yes
ip addr show | egrep -i "inet|mtu"
exit 0
