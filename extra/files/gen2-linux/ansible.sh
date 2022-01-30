#!/usr/bin/env bash

# script to install and remove ansible
# vars
# set ansible-core version due to python requirements in ansible 2.12

ansible_core="2.11.7"

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

function install_ansible {
  echo "Starting ansible installation step, ansible-core in version: $ansible_core"
  /usr/bin/python3 -m pip install --upgrade pip
  /usr/bin/python3 -m pip install --upgrade jmespath jsonlint yamllint ansible-core==$ansible_core ansible pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp
  /usr/local/bin/ansible-galaxy collection install --upgrade ansible.posix
  /usr/local/bin/ansible-galaxy collection install --upgrade community.general
  /usr/local/bin/ansible-galaxy collection install --upgrade community.crypto
}

function check_ansible {
  echo "Checking for ansible presence"
  which ansible
  which ansible-playbook
  ansible --version||true
  ansible-playbook --version||true
}

function add_path {
  echo "Adding /usr/local/bin to PATH"
  echo "export PATH=/usr/local/bin:$PATH" >>~/.bashrc
  source ~/.bashrc
  cat ~/.bashrc
}

if [ "$INSTALL" == "true" ] && [[ "$OS" =~ rhel|centos|fedora ]];then
  echo "Installing ansible on RHEL/CENTOS/FEDORA/ORACLE"
  add_path
  if which dnf;then
    manager=dnf
  else
    manager=yum
  fi
  $manager clean all -y
  $manager makecache -y
  $manager remove ansible ansible-base ansible-core -y||true
  $manager install ca-certificates python3 python3-devel python3-pip python3-wheel krb5-devel krb5-workstation -y
  $manager install python3-setuptools python3-psutil -y
  /usr/bin/python3 -m pip install --upgrade setuptools-rust
  install_ansible
  check_ansible
fi

if [ "$INSTALL" == "false" ] && [[ "$OS" =~ rhel|centos|fedora ]];then
  echo "Removing ansible on RHEL/related"
  if which dnf;then
    manager=dnf
  else
    manager=yum
  fi
  $manager clean all -y
  $manager makecache -y
  /usr/bin/python3 -m pip uninstall jmespath jsonlint yamllint ansible-core ansible setuptools-rust pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp -y
  rm -rfv /root/.ansible||true
  rm -rfv /root/.cache||true
  rm -rfv /home/vagrant/.ansible||true
  rm -rfv /home/vagrant/.cache||true
  $manager clean -y all
fi

if [ "$INSTALL" == "true" ] && [[ "$OS" =~ debian|ubuntu ]];then
  echo "Installing ansible on Ubuntu/Debian"
  add_path
  apt-get clean all -y
  apt-get update -y
  apt-get purge ansible ansible-base ansible-core -y||true
  apt-get install ca-certificates python3 python3-dev python3-pip python3-wheel libkrb5-dev -y
  install_ansible
  check_ansible
fi

if [ "$INSTALL" == "false" ] && [[ "$OS" =~ debian|ubuntu ]];then
  echo "Removing ansible on Ubuntu/Debian"
  apt-get clean all -y
  apt-get update -y
  /usr/bin/python3 -m pip uninstall jmespath jsonlint yamllint ansible-core ansible pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp -y
  rm -rfv /root/.ansible||true
  rm -rfv /root/.cache||true
  rm -rfv /home/vagrant/.ansible||true
  rm -rfv /home/vagrant/.cache||true
fi
