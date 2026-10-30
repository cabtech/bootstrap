#!/bin/bash

arch="amd64"

version="v4.15.1"
latest=$(curl -s https://api.github.com/repos/tofuutils/tenv/releases/latest | jq -r .tag_name)
if [[ "$latest" != "$version" ]]; then
	echo "INFO :: Newer version ($latest) is available"
fi

target=/var/tmp/tenv_"${version}_${arch}".deb
if [[ ! -e "${target}" ]]; then
	echo "INFO :: Downloading $version"
	curl -o "${target}" -LO "https://github.com/tofuutils/tenv/releases/latest/download/tenv_${version}_${arch}.deb"
fi
sudo dpkg -i "${target}"

target=/etc/bash_completion.d/tenv
if [[ ! -e "$target" ]]; then
	echo "INFO :: Installing bash completion"
	tenv completion bash | sudo tee "${target}" > /dev/null
fi

exit 0
