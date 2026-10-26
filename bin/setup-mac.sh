#!/bin/bash
set -euo pipefail
_tmp=$(dirname "$0")
base=$(cd "$_tmp"/.. && pwd)
unset _tmp

# --------------------------------

do_apps=false
do_dirs=false
while getopts ad arg; do
	case $arg in
		a) do_apps=true;;
		d) do_dirs=true;;
		*) echo "ERROR :: bad arg"; exit 42;;
	esac
done

# --------------------------------
# install apps

if $do_apps; then
    mkdir -p ~/.config && touch ~/.config/starship.toml

	brew install --cask firefox
	brew install --cask ghostty
	brew install --cask iterm2
	brew install curl direnv docker fd gh git gpg gzip htop
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

if $do_dirs; then
	mkdir -p ~/bin ~/etc ~/etc/bash.d ~/src ~/tmp ~/work
	cp $base/etc/bash.d/core.sh ~/etc/bash.d
	cp $base/etc/bash.d/git.sh ~/etc/bash.d

	idem="133f23ee-5617-4082-9e1f-c78167e89b75"
	grep -q ${idem} ~/.zshrc
	if (($?!=0)); then
		echo "# $idem" >> ~/.zshrc
		echo '[[ -d ~/etc/bash.d ]] && for ff in ~/etc/bash.d/*.sh; do source $ff; done # ansible' >> ~/.zshrc
		echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
		echo 'eval "$(starship init zsh)"' >> ~/.zshrc
		# echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
		# echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
	fi
fi

# --------------------------------

exit 0
