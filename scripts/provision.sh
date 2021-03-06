#!/usr/bin/env bash
set -euxo pipefail

source build_options.sh

time ansible-playbook -i localhost, ../playbooks/provision.yml -vvv -e ansible_python_interpreter=${PYTHON}
