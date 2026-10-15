#!/bin/bash
base=$( cd $(dirname $0)/.. && pwd)

sudo apt install curl gh gzip jq ncal net-tools yamllint
sudo apt install fd-find
sudo snap install astral-uv --classic
sudo snap install ghostty --classic
sudo snap install ripgrep --classic
sudo snap install ruff

if [[ -e /usr/local/bin/starship ]]; then
	echo "INFO :: Starship is already installed"
else
	mkdir -p ~/.config && touch ~/.config/starship.toml
	$base/bin/install-starship.sh -v v1.26.0
fi

exit 0
