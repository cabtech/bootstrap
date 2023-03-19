#!/bin/bash

# --------------------------------
# on the new guest

sudo apt update --yes
sudo apt install git openssh-server --yes
# sudo ssh-keygen -A
ip addr show | egrep -i "inet|mtu"

mkdir -p ~/.ssh/cfg.d ~/.ssh/keys ~/work
chmod 700 ~/.ssh ~/.ssh/cfg.d ~/.ssh/keys
touch ~/.ssh/config
chmod 600 ~/.ssh/config
echo "StrictHostKeyChecking=no" > ~/.ssh/cfg.d/00.cfg

cd ~/work
git clone https://github.com/cabtech/bootstrap.git
git clone https://github.com/cabtech/ansible-scripts.git
echo 'export PATH=${PATH}:~/work/ansible-scripts' >> ~/.bashrc

# --------------------------------
# on the source guest

# update  ~/.ssh/cfg.d/$host.cfg
# ct-mkssh.sh -dx
# ssh-copy-id -i ~/.ssh/keys/HOST/KEY user@guest
# scp ~/.ssh/keys/HOST/KEY newGuest:~/.ssh/keys/HOST
# loop(otherHosts) scp ~/.ssh/cfg.d/HOST.cfg guest:.ssh/cfg.d/HOST.cfg
# loop(otherHosts) ssh guest ct-mkssh.sh -dx

# --------------------------------

exit 0
