#!/bin/bash
sudo apt install curl gzip jq ncal net-tools yamllint
sudo snap install astral-uv --classic
sudo snap install ghostty --classic
sudo snap install ruff
# install starship
mkdir -p ~/.config && touch ~/.config/starship.toml
exit 0
