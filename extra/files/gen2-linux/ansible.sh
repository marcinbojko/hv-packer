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
# what os we're dealing with
OS=$(grep -e '^ID_LIKE=' /etc/os-release|tr -d '"'|sed -e "s/^ID_LIKE=//"|tr "[:upper:]" "[:lower:]")

if [ -z "$OS" ];then
echo "Couldn't recognise os, exiting"
exit 1
else
echo "Found: $OS"
fi

if [ -z "$INSTALL" ];then
  usage
  exit 1
fi

echo "Found os: $OS"

function install_ansible {
  /usr/bin/python3 -m pip install --upgrade pip
  /usr/bin/python3 -m pip install --upgrade jmespath jsonlint yamllint ansible-base ansible pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp
  /usr/local/bin/ansible-galaxy collection install ansible.posix
  /usr/local/bin/ansible-galaxy collection install community.general
  /usr/local/bin/ansible-galaxy collection install community.crypto
}

if [ "$INSTALL" == "true" ] && [[ "$OS" =~ rhel|centos|fodora ]];then
  echo "Installing ansible on RHEL/related"
  yum clean all -y
  yum makecache -y
  yum remove ansible ansible-base -y||true
  yum install python3 python3-devel python3-pip python3-wheel krb5-devel krb5-workstation -y
  yum install cowsay -y
  yum install python3-setuptools python3-psutil -y
  /usr/bin/python3 -m pip install --upgrade setuptools-rust
  install_ansible
fi

if [ "$INSTALL" == "false" ] && [[ "$OS" =~ rhel|centos|fedora ]];then
  echo "Removing ansible on RHEL/related"
  yum clean all -y
  yum makecache -y
  /usr/bin/python3 -m pip uninstall jmespath jsonlint yamllint ansible-base ansible setuptools-rust pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp -y
  rm -rfv /root/.ansible||true
  rm -rfv /root/.cache||true
  rm -rfv /home/vagrant/.ansible||true
  rm -rfv /home/vagrant/.cache||true
  yum clean -y all
fi

if [ "$INSTALL" == "true" ] && [[ "$OS" =~ debian|ubuntu ]];then
  echo "Installing ansible on Ubuntu/Debian"
  apt-get clean all -y
  apt-get update -y
  apt-get purge ansible ansible-base -y||true
  apt-get install python3 python3-dev python3-pip python3-wheel libkrb5-dev -y
  apt-get install cowsay -y
  install_ansible
fi

if [ "$INSTALL" == "false" ] && [[ "$OS" =~ debian|ubuntu ]];then
  echo "Removing ansible on Ubuntu/Debian"
  apt-get clean all -y
  apt-get update -y
  /usr/bin/python3 -m pip uninstall  jmespath jsonlint yamllint ansible-base ansible pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp -y
  rm -rfv /root/.ansible||true
  rm -rfv /root/.cache||true
  rm -rfv /home/vagrant/.ansible||true
  rm -rfv /home/vagrant/.cache||true
fi


