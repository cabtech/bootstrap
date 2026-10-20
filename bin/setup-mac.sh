#!/bin/bash
set -euo pipefail
_tmp=$(dirname "$0")
base=$(cd "$_tmp"/.. && pwd)
unset _tmp

# install brew (pinned commit of Homebrew/install; bump both values together after reviewing)
brew_commit=be041513824fd2666a0e93cf5c3b0ca3bb0eb4b6
brew_sha256=5f333bbe53bc490e51e7ccb1df8779b3dd6ee73a1a7379efda216edb08ccb148
brew_tmp=$(mktemp)
trap 'rm -f "$brew_tmp"' EXIT
curl -o "$brew_tmp" -fsSL "https://raw.githubusercontent.com/Homebrew/install/$brew_commit/install.sh"
if command -v sha256sum >/dev/null; then
	actual=$(sha256sum "$brew_tmp" | cut -d' ' -f1)
else
	actual=$(shasum -a 256 "$brew_tmp" | cut -d' ' -f1)
fi
if [[ "$actual" != "$brew_sha256" ]]; then
	echo "ERROR :: install-brew.sh checksum mismatch (got $actual)" >&2
	exit 1
fi
mv "$brew_tmp" "$base"/bin/install-brew.sh
chmod 755 "$base"/bin/install-brew.sh

# do the actual install

# install apps
if false; then
brew install --cask firefox
brew install --cask iterm2
brew install curl docker gpg gzip htop nmap sha2 wget
brew install gh jq python3 starship yq
brew install tfenv

curl -o Ghostty.dmg -fsSL "https://release.files.ghostty.org/1.3.1/Ghostty.dmg"

# gzip ncal net-tools yamllint
# fd-find
# astral-uv
# ghostty
# ripgrep
# ruff
fi

exit 0
