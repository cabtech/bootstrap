#!/bin/bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
if [[ ! -e /usr/share/keyrings/netbird-archive-keyring.gpg ]]; then
curl -sSL https://pkgs.netbird.io/debian/public.key | sudo gpg --dearmor --output /usr/share/keyrings/netbird-archive-keyring.gpg
fi
if [[ ! -e /etc/apt/sources.list.d/netbird.list ]]; then
echo 'deb [signed-by=/usr/share/keyrings/netbird-archive-keyring.gpg] https://pkgs.netbird.io/debian stable main' | sudo tee /etc/apt/sources.list.d/netbird.list
fi
sudo apt-get update
sudo apt-get install netbird
sudo apt-get install netbird-ui libgtk-4-1 libwebkitgtk-6.0-4 xdg-utils
exit 0
