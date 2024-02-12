#!/bin/bash

base=$(cd $(dirname $0)/.. && pwd)

target=~/src/cabtech
mkdir -p $target
cd $target
git clone https://github.com/cabtech/ansible-scripts.git
git clone https://github.com/cabtech/bootstrap.git
git clone https://github.com/cabtech/terraform-scripts.git

target=~/work/cabtech
mkdir -p $target
cd $target
git clone git@github.com:cabtech/ansible-scripts.git
git clone git@github.com:cabtech/bootstrap.git
git clone git@github.com:cabtech/terraform-scripts.git

target=~/work/cabtech/roles
mkdir -p $target
cd $target
for role in $(cat $base/etc/cabtech-roles.cfg); do
git clone git@github.com:cabtech/${role}.git
done

~/src/cabtech/ansible-scripts/bin/ct-mkssh.sh -dx

exit 0
