#!/bin/bash

usage() { echo "Usage: $0 [-i <true|false> Install or uninstall ansible ]" 1>&2; }

while getopts :i:  option
    do
      case "${option}"
      in
      i)
        INSTALL="${OPTARG}"
        ;;
      *)
        usage
        ;;
      esac
    done

if [ "$INSTALL" == "true" ];then
  yum clean all -y
  yum makecache -y
  yum remove ansible -y||true
  yum install python3 python3-devel python3-pip python3-wheel -y
  yum install python3-setuptools python3-psutil -y
  /usr/bin/python3 -m pip install --upgrade pip
  /usr/bin/python3 -m pip install --upgrade jmespath jsonlint yamllint ansible-base ansible setuptools-rust
  /usr/local/bin/ansible-galaxy collection install ansible.posix
  /usr/local/bin/ansible-galaxy collection install community.general
#  /usr/local/bin/ansible-galaxy collection install community.docker
#  /usr/local/bin/ansible-galaxy collection install ansible.windows
#  /usr/local/bin/ansible-galaxy collection install community.windows
#  /usr/local/bin/ansible-galaxy collection install chocolatey.chocolatey
fi

if [ "$INSTALL" == "false" ];then
  yum clean all -y
  yum makecache -y
  /usr/bin/python3 -m pip uninstall  jmespath jsonlint yamllint ansible-base ansible setuptools-rust -y
  rm -rf /root/.ansible||true
  rm -rf /root/.cache||true
  yum clean -y all
fi

if [ -z "$INSTALL" ];then
  usage
fi
exit

