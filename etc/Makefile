.PHONY: clean init upgrade

lint: .lintterraform .lintyaml

.lintiam: iam_policies/*.json
	parliament --directory iam_policies --exclude_pattern "iam_policies/skip_scan" --include_policy_extension json
	@touch $@

.lintjson: terragen.json
	python3 -m json.tool $< > $@

.lintterraform: *.tf
	terraform fmt
	terraform validate
	@echo "Uncomment tflint command"
	#tflint --config=.config/tflint.hcl
	@touch $@

.lintyaml: *.yml */*.yml .config/yamllint
	yamllint -c .config/yamllint *.yml *vars/*.yml
	@touch $@

tflintinit:
	tflint --init --config=.config/tflint.hcl

init-uv:
	uv python install 3.14
	uv init
	uv python pin python3.14
	uv add -r    requirements.raw
	uv export -o requirements.txt > /dev/null

update-uv:
	uv add -r    requirements.raw
	uv export -o requirements.txt > /dev/null

# --------------------------------

dirs:
	mkdir -p .config group_vars host_vars iam_policies/skip_scan inv.d roles vars
	chmod 755 group_vars host_vars inv.d

hosts:
	ct-inventory-uv.sh > /dev/null
	/bin/cp -p inventory-*.cfg ~/.ssh/cfg.d
	ct-mkssh.sh -x

inventory:
	uv run ansible-inventory --list --inventory inv.d/

jobs:
	ct-play-uv.sh -r ansible.env -p playbooks/manage-nomad-jobs.yml -l nomad -Rd
jobs_:
	ct-play-uv.sh -r ansible.env -p playbooks/manage-nomad-jobs.yml -l nomad -Rd -x

links:
	@mkdir -p inv.d
	ln -fs ../roles/galaxy/ansible-role-ct-terragen/files/cloud_inventory.py inv.d/cloud_inventory.py
	ln -fs    roles/galaxy/ansible-role-ct-terragen/playbooks playbooks

roles: requirements.yml
	uv run ansible-galaxy install -r requirements.yml -p roles/galaxy

users:
	ct-play-uv.sh -r ansible.env -p playbooks/manage-linux-users.yml -l uber -Rd
users_:
	ct-play-uv.sh -r ansible.env -p playbooks/manage-linux-users.yml -l uber -Rd -x

# --------------------------------

hcl: .lintyaml
	ct-play-uv.sh -r ansible.env -p site.yml -l localhost -Rd
hcl_: .lintyaml
	ct-play-uv.sh -r ansible.env -p site.yml -l localhost -Rd -x

init:
	terraform init
upgrade:
	terraform init -upgrade

plan: .lintterraform
	terraform plan -out plan
plan_:
	terraform plan -out plan

apply: .lintterraform plan
	terraform apply plan
	ct-inventory.sh > /dev/null
	/bin/cp -p inventory-*.cfg ~/.ssh/cfg.d
	ct-mkssh.sh -x

# --------------------------------
# by cloud

alicloud:
	ct-play-uv.sh -r ansible.env -p site.yml -l alicloud -Rd
alicloud_:
	ct-play-uv.sh -r ansible.env -p site.yml -l alicloud -Rd -x

aws:
	ct-play-uv.sh -r ansible.env -p site.yml -l aws -Rd
aws_:
	ct-play-uv.sh -r ansible.env -p site.yml -l aws -Rd -x

azure:
	ct-play-uv.sh -r ansible.env -p site.yml -l azure -Rd
azure_:
	ct-play-uv.sh -r ansible.env -p site.yml -l azure -Rd -x

docean:
	ct-play-uv.sh -r ansible.env -p site.yml -l docean -Rd
docean_:
	ct-play-uv.sh -r ansible.env -p site.yml -l docean -Rd -x

equinix:
	ct-play-uv.sh -r ansible.env -p site.yml -l equinix -Rd
equinix_:
	ct-play-uv.sh -r ansible.env -p site.yml -l equinix -Rd -x

gcp:
	ct-play-uv.sh -r ansible.env -p site.yml -l gcp -Rd
gcp_:
	ct-play-uv.sh -r ansible.env -p site.yml -l gcp -Rd -x

linode:
	ct-play-uv.sh -r ansible.env -p site.yml -l linode -Rd
linode_:
	ct-play-uv.sh -r ansible.env -p site.yml -l linode -Rd -x

ovh:
	ct-play-uv.sh -r ansible.env -p site.yml -l ovh -Rd
ovh_:
	ct-play-uv.sh -r ansible.env -p site.yml -l ovh -Rd -x

vultr:
	ct-play-uv.sh -r ansible.env -p site.yml -l vultr -Rd
vultr_:
	ct-play-uv.sh -r ansible.env -p site.yml -l vultr -Rd -x

# --------------------------------
# by function

bastion:
	ct-play-uv.sh -r ansible.env -p site.yml -l bastion -Rd
bastion_:
	ct-play-uv.sh -r ansible.env -p site.yml -l bastion -Rd -x

build:
	ct-play-uv.sh -r ansible.env -p site.yml -l build -Rd
build_:
	ct-play-uv.sh -r ansible.env -p site.yml -l build -Rd -x

consul:
	ct-play-uv.sh -r ansible.env -p site.yml -l consul -Rd
consul_:
	ct-play-uv.sh -r ansible.env -p site.yml -l consul -Rd -x

grafana:
	ct-play-uv.sh -r ansible.env -p site.yml -l grafana -Rd
grafana_:
	ct-play-uv.sh -r ansible.env -p site.yml -l grafana -Rd -x

internet:
	ct-play-uv.sh -r ansible.env -p site.yml -l internet -Rd
internet_:
	ct-play-uv.sh -r ansible.env -p site.yml -l internet -Rd -x

jenkins:
	ct-play-uv.sh -r ansible.env -p site.yml -l jenkins -Rd
jenkins_:
	ct-play-uv.sh -r ansible.env -p site.yml -l jenkins -Rd -x

nginx:
	ct-play-uv.sh -r ansible.env -p site.yml -l nginx -Rd
nginx_:
	ct-play-uv.sh -r ansible.env -p site.yml -l nginx -Rd -x

nomad:
	ct-play-uv.sh -r ansible.env -p site.yml -l nomad -Rd
nomad_:
	ct-play-uv.sh -r ansible.env -p site.yml -l nomad -Rd -x

postgres:
	ct-play-uv.sh -r ansible.env -p site.yml -l postgres -Rd
postgres_:
	ct-play-uv.sh -r ansible.env -p site.yml -l postgres -Rd -x

svc:
	ct-play-uv.sh -r ansible.env -p site.yml -l svc -Rd
svc_:
	ct-play-uv.sh -r ansible.env -p site.yml -l svc -Rd -x

trading:
	ct-play-uv.sh -r ansible.env -p site.yml -l trading -Rd
trading_:
	ct-play-uv.sh -r ansible.env -p site.yml -l trading -Rd -x

twingate:
	ct-play-uv.sh -r ansible.env -p site.yml -l twingate -Rd
twingate_:
	ct-play-uv.sh -r ansible.env -p site.yml -l twingate -Rd -x

uber:
	ct-play-uv.sh -r ansible.env -p site.yml -l uber -Rd
uber_:
	ct-play-uv.sh -r ansible.env -p site.yml -l uber -Rd -x

vault:
	ct-play-uv.sh -r ansible.env -p site.yml -l vault -Rd
vault_:
	ct-play-uv.sh -r ansible.env -p site.yml -l vault -Rd -x

vpn:
	ct-play-uv.sh -r ansible.env -p site.yml -l vpn -Rd
vpn_:
	ct-play-uv.sh -r ansible.env -p site.yml -l vpn -Rd -x

# --------------------------------
# by role

rcertbot:
	ct-play-uv.sh -r ansible.env -p site.yml -l uber -t ct-certbot -Rd
rcertbot_:
	ct-play-uv.sh -r ansible.env -p site.yml -l uber -t ct-certbot -Rd -x

rfail2ban:
	ct-play-uv.sh -r ansible.env -p site.yml -l internet -t ct-fail2ban,ct-facts -Rd
rfail2ban_:
	ct-play-uv.sh -r ansible.env -p site.yml -l internet -t ct-fail2ban,ct-facts -Rd -x

rgrafana:
	ct-play-uv.sh -r ansible.env -p site.yml -l grafana -t ct-grafana -Rd
rgrafana_:
	ct-play-uv.sh -r ansible.env -p site.yml -l grafana -t ct-grafana -Rd -x

rjenkins:
	ct-play-uv.sh -r ansible.env -p site.yml -l jenkins -t ct-jenkins -Rd
rjenkins_:
	ct-play-uv.sh -r ansible.env -p site.yml -l jenkins -t ct-jenkins -Rd -x

rnetdata:
	ct-play-uv.sh -r ansible.env -p site.yml -l uber -t ct-netdata -Rd
rnetdata_:
	ct-play-uv.sh -r ansible.env -p site.yml -l uber -t ct-netdata -Rd -x

rnginx:
	ct-play-uv.sh -r ansible.env -p site.yml -l nginx -t ct-nginx -Rd
rnginx_:
	ct-play-uv.sh -r ansible.env -p site.yml -l nginx -t ct-nginx -Rd -x

rpinger:
	ct-play-uv.sh -r ansible.env -p site.yml -l pinger -t ct-pinger -Rd
rpinger_:
	ct-play-uv.sh -r ansible.env -p site.yml -l pinger -t ct-pinger -Rd -x

rtrading:
	ct-play-uv.sh -r ansible.env -p site.yml -l trading -t ct-trading -Rd
rtrading_:
	ct-play-uv.sh -r ansible.env -p site.yml -l trading -t ct-trading -Rd -x

rtwingate:
	ct-play-uv.sh -r ansible.env -p site.yml -l twingate -t ct-twingate -Rd
rtwingate_:
	ct-play-uv.sh -r ansible.env -p site.yml -l twingate -t ct-twingate -Rd -x

rvault:
	ct-play-uv.sh -r ansible.env -p site.yml -l vault -t ct-vault -Rd
rvault_:
	ct-play-uv.sh -r ansible.env -p site.yml -l vault -t ct-vault -Rd -x

# --------------------------------

clean:
	@/bin/rm -f .lint* plan

# --------------------------------
