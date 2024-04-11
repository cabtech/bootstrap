#!/bin/bash

baseurl="https://github.com/cabtech"

repos="ansible-role-app-aptmirror ansible-role-app-brave ansible-role-app-clamav ansible-role-app-datadog ansible-role-app-dnsmasq ansible-role-app-docker ansible-role-app-duoauthproxy ansible-role-app-envoy ansible-role-app-fail2ban ansible-role-app-freeradius ansible-role-app-gitlab ansible-role-app-granulate ansible-role-app-kafka ansible-role-app-nginx ansible-role-app-opengrok ansible-role-app-tor ansible-role-app-zookeeper ansible-role-distro-centos ansible-role-distro-ubuntu ansible-role-family-debian ansible-role-family-redhat ansible-role-hashicorp-common ansible-role-hashicorp-consul ansible-role-hashicorp-nomad ansible-role-hashicorp-terraform ansible-role-hashicorp-vault ansible-role-hashicorp-vaultmanager ansible-role-opsys-unix ansible-role-util-certbot ansible-role-util-debug ansible-role-util-facts ansible-role-util-gcloud ansible-role-util-git ansible-role-util-openjdk ansible-role-util-osbootstrap ansible-role-util-python ansible-role-util-sublime ansible-role-util-terragen ansible-role-util-user ansible-scripts cartman terraform-scripts"

for repo in $repos; do
	if [[ ! -d "$repo" ]]; then
		git clone ${baseurl}/${repo}.git
	else
		echo "$repo exists"
	fi
done

exit 0
