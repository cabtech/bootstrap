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

# --------------------------------
# install apps

if $do_apps; then
	brew install --cask firefox
	brew install --cask ghostty
	brew install --cask iterm2
	brew install curl docker fd gh git gpg gzip htop
	brew install jq net-tools nmap python3 ripgrep
	brew install ruff sha2 starship tfenv uv wget
	brew install yamllint yq
	# cal command
	echo ""
	echo "install Malwarebytes"
	echo "install Malwarebytes Browser Guard for Firefox"
	echo "install Proton Pass extension for Firefox"
fi

# --------------------------------

exit 0
