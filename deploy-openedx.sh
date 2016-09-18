#!/bin/bash

set -x
export OPENEDX_RELEASE=${1:-"named-release/dogwood.rc"}
CONFIG_REPO=https://github.com/edx/configuration.git
ANSIBLE_ROOT=/edx/app/edx_ansible

wget https://raw.githubusercontent.com/edx/configuration/master/util/install/ansible-bootstrap.sh -O- | bash

adduser --disabled-password --gecos '' edx-ansible --home /edx/app/edx_ansible
usermod -aG sudo edx-ansible

bash -c "cat << EOF > extra-vars.yml
---
edx_platform_version: \"$OPENEDX_RELEASE\"
certs_version: \"$OPENEDX_RELEASE\"
forum_version: \"$OPENEDX_RELEASE\"
xqueue_version: \"$OPENEDX_RELEASE\"
configuration_version: \"$OPENEDX_RELEASE\"
edx_ansible_source_repo: \"$CONFIG_REPO\"
COMMON_SSH_PASSWORD_AUTH: \"yes\"
EOF"

sudo -u edx-ansible cp *.yml $ANSIBLE_ROOT

cd /tmp
git clone $CONFIG_REPO

cd configuration
git checkout $OPENEDX_RELEASE
pip install -r requirements.txt

cd playbooks
ansible-playbook -i localhost, -c local vagrant-fullstack.yml -e@$ANSIBLE_ROOT/server-vars.yml -e@$ANSIBLE_ROOT/extra-vars.yml
