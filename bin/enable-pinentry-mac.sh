#!/bin/bash

set -e

fname=~/.gnupg/gpg-agent.conf
pinentry=$(brew --prefix)/bin/pinentry-mac

if [[ ! -x "${pinentry}" ]]; then
	echo "ERROR :: ${pinentry} not found, run: brew install pinentry-mac"
	exit 4
fi

mkdir -p ~/.gnupg && chmod 700 ~/.gnupg
touch "${fname}"

# Remove any earlier copies so that reruns don't add duplicates
sed -i '' -E '/^(pinentry-program|default-cache-ttl|max-cache-ttl)[[:space:]]/d' "${fname}"
{
	echo "pinentry-program ${pinentry}"
	echo "default-cache-ttl 3600"  # forget the passphrase after 1 hour idle
	echo "max-cache-ttl 28800"     # and after 8 hours regardless of use
} >> "${fname}"
gpgconf --kill gpg-agent

# shellcheck disable=SC2016 # tty has to run at each shell start
line='export GPG_TTY=$(tty)'
grep -qxF "${line}" ~/.zshrc 2>/dev/null || echo "${line}" >> ~/.zshrc

exit 0
