lint: lintjson lintyaml

lintjson:
	jq . template/terragen.json > /dev/null

lintyaml:
	yamllint -c etc/linters/yamllint template/*.yml

# end
