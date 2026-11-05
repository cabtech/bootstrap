#!/bin/bash
# shellcheck disable=SC2016
# shellcheck disable=SC2181
# shellcheck disable=SC2129

_tmp=$(dirname "$0")
base=$( cd "$_tmp"/.. && pwd)
unset _tmp

# --------------------------------

mkdir -p ~/.config
mkdir -p ~/bin ~/etc ~/etc/bash.d ~/src ~/tmp ~/work

# --------------------------------

sudo apt install curl direnv fd-find gh gnupg gzip jq ncal net-tools pass pinentry-curses yamllint yq

sudo snap install astral-uv --classic
sudo snap install ghostty --classic
sudo snap install htop
sudo snap install ripgrep --classic
sudo snap install ruff

git config --global init.defaultBranch main

# --------------------------------

if [[ -e /usr/local/bin/starship ]]; then
	echo "INFO :: Starship is already installed"
else
	"$base"/bin/install-starship.sh -v v1.26.0
fi

fname=~/.config/starship.toml
if [[ ! -e "$fname" ]]; then
	cp "$base"/etc/starship.toml "$fname"
fi

# --------------------------------

idem="133f23ee-5617-4082-9e1f-c78167e89b75"
grep -q ${idem} ~/.bashrc
if (($?!=0)); then
	echo "# $idem" >> ~/.bashrc
	echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
	echo '[[ -d ~/etc/bash.d ]] && for ff in ~/etc/bash.d/*.sh; do source $ff; done # ansible' >> ~/.bashrc
	echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
	# echo 'eval "$(starship init bash)"' >> ~/.bashrc
	# echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
fi

# --------------------------------

mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
fname=~/.gnupg/gpg-agent.conf
if [[ ! -e "$fname" ]]; then
cat << ENDCAT > $fname
default-cache-ttl 3600
max-cache-ttl 28800
pinentry-program /usr/bin/pinentry-curses
ENDCAT
fi

# --------------------------------

cd ~/etc/bash.d || exit 99

ln -s ~/src/cabtech/bootstrap/etc/bash.d/cabtech.sh
ln -s ~/src/cabtech/bootstrap/etc/bash.d/core.sh
ln -s ~/src/cabtech/bootstrap/etc/bash.d/direnv.sh
ln -s ~/src/cabtech/bootstrap/etc/bash.d/git.sh
ln -s ~/src/cabtech/bootstrap/etc/bash.d/starship.sh
ln -s ~/src/cabtech/bootstrap/etc/bash.d/terraform.sh

# --------------------------------

echo ""
echo "Goto https://proton.me/blog/proton-drive-cli"
exit 0
