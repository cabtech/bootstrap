lint: lintjson lintyaml

lintjson:
	jq . template/terragen.json > /dev/null
	jq . template/credentials.json > /dev/null
	jq . template/preferences.json > /dev/null

lintyaml:
	yamllint -c etc/linters/yamllint template/*.yml

# end
