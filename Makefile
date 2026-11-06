lint: lintjson lintshell lintyaml

lintjson:
	jq . template/terragen.json > /dev/null
	jq . template/credentials.json > /dev/null
	jq . template/preferences.json > /dev/null

lintshell:
	shellcheck bin/clone-repos.sh bin/install-starship.sh bin/install-tenv.sh bin/multi-git.sh bin/setup-*.sh

lintyaml:
	yamllint -c etc/yamllint template/*.yml

# end
