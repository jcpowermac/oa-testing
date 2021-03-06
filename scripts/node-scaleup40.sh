#!/usr/bin/env bash
set -euxo pipefail

source ansible/hacking/env-setup

source build_options.sh

# Use the extracted `oc` when running playbooks
PATH=$PWD/bin:$PATH
which oc

${PYTHON} $(which ansible) --version

${PYTHON} $(which ansible-inventory) -i inventory/hosts --list --yaml

pushd openshift-ansible

time ${PYTHON} $(which ansible-playbook) -i ../inventory/hosts playbooks/scaleup.yml -vvv

popd
