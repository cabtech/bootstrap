#!/bin/bash
set -euo pipefail
_tmp=$(dirname "$0")
base=$(cd "$_tmp"/.. && pwd)
unset _tmp

# --------------------------------

do_apps=false
do_dirs=false
do_msgs=true
while getopts Madm arg; do
	case $arg in
		M) do_msgs=false;;
		a) do_apps=true;;
		d) do_dirs=true;;
		m) do_msgs=true;;
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
	brew install awscli curl direnv docker fd gh git gpg gzip htop
	brew install iproute2mac jq nmap python3 ripgrep
	brew install ruff sha2 starship tfenv util-linux uv wget
	brew install yamllint yq
fi

if $do_dirs; then
	mkdir -p ~/.aws ~/.ssh/cfg.d ~/.ssh/keys/github ~/bin ~/etc ~/etc/bash.d ~/src ~/tmp ~/work
	cp $base/etc/bash.d/cabtech.sh ~/etc/bash.d
	cp $base/etc/bash.d/core.sh ~/etc/bash.d
	cp $base/etc/bash.d/git.sh ~/etc/bash.d
	cp $base/etc/bash.d/macos.sh ~/etc/bash.d

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

if $do_msgs; then
	echo ""
	echo "# find a way to install net-tools"
	echo "# install Chrome (web)"
	echo "# sign into Google Account"
	echo "# install Malwarebytes (web)"
	echo "# install Malwarebytes Browser Guard for Chrome and Firefox"
	echo "# install Proton Pass extension for Chrome and Firefox"
	echo "# sign in to App Store..."
	echo "# install Telegram (app store)"
	echo "# install WhatsApp (app store)"
fi

# --------------------------------

exit 0
