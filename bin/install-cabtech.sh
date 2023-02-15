#!/bin/bash

target=~/src/cabtech
mkdir -p $target
cd $target
git clone https://github.com/cabtech/ansible-scripts.git
git clone https://github.com/cabtech/bootstrap.git
git clone https://github.com/cabtech/terraform-scripts.git

target=~/work/cabtech
mkdir -p $target
cd $target
if false; then
git clone git@github.com:cabtech/ansible-scripts.git
git clone git@github.com:cabtech/bootstrap.git
git clone git@github.com:cabtech/terraform-scripts.git
fi

exit 0
