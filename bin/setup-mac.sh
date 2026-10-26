#!/bin/bash
set -euo pipefail
_tmp=$(dirname "$0")
base=$(cd "$_tmp"/.. && pwd)
unset _tmp

# --------------------------------

do_apps=false
while getopts a arg; do
	case $arg in
		a) do_apps=true;;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

mkdir -p ~/bin ~/etc ~/src ~/tmp ~/work

# --------------------------------
# install apps

if $do_apps; then
    mkdir -p ~/.config && touch ~/.config/starship.toml

	brew install --cask firefox
	brew install --cask ghostty
	brew install --cask iterm2
	brew install curl docker fd gh git gpg gzip htop
	brew install jq nmap python3 ripgrep
	brew install ruff sha2 starship tfenv uv wget
	brew install yamllint yq

	echo ""
	echo "find a way to install net-tools and cal"
	echo ""
	echo "install Malwarebytes"
	echo "install Malwarebytes Browser Guard for Firefox"
	echo "install Proton Pass extension for Firefox"
fi

mkdir -p ~/bin ~/etc ~/etc/bash.d ~/src ~/tmp ~/work
cp $base/etc/bash.d/core.sh ~/etc/bash.d
cp $base/etc/bash.d/git.sh ~/etc/bash.d
grep -q 'done # ansible' ~/.zshrc
if (($?!=0)); then
	echo "[[ -d ~/etc/bash.d ]] && for ff in ~/etc/bash.d/*.sh; do source $ff; done # ansible" >> ~/.zshrc
fi

# --------------------------------

exit 0
