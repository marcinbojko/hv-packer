#!/usr/bin/env bash

# script to install and remove ansible
# vars
# set ansible-core version due to python requirements in ansible 2.12

ansible_core="2.13.1"

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
VERSION_ID=$(grep -e '^VERSION_ID=' /etc/os-release|tr -d '"'|sed -e "s/^VERSION_ID=//"|tr "[:upper:]" "[:lower:]"|cut -c1-1)

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
  case "$VERSION_ID" in
  "7")
    echo "Found os: $OS and release: $VERSION_ID"
    /usr/bin/python3 -m pip install --upgrade jmespath jsonlint yamllint ansible-core==2.11.11 pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp ;;
  "8")
    echo "Found os: $OS and release: $VERSION_ID"
    /usr/bin/python3 -m pip install --upgrade jmespath jsonlint yamllint ansible-core==$ansible_core pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp ;;
  "9")
    echo "Found os: $OS and release: $VERSION_ID"
    /usr/bin/python3 -m pip install --upgrade jmespath jsonlint yamllint ansible-core==$ansible_core pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp ;;
   *)
   echo "Found os: $OS and release: $VERSION_ID"
   /usr/bin/python3 -m pip install --upgrade jmespath jsonlint yamllint ansible-core==$ansible_core pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp ;;
  esac
  # build a block to supress warnings and other ansible configs
  mkdir -p /etc/ansible && chmod 755 /etc/ansible
  echo "[defaults]" > /etc/ansible/ansible.cfg
  echo "deprecation_warnings=False" >> /etc/ansible/ansible.cfg

  # let's install required modules, use --upgrade if possible
  /usr/local/bin/ansible-galaxy collection install --upgrade ansible.posix
  /usr/local/bin/ansible-galaxy collection install --upgrade community.general
  /usr/local/bin/ansible-galaxy collection install --upgrade community.crypto
}

function check_ansible {
  echo "Checking for ansible presence"
  if command -v ansible >/dev/null 2>&1;then
    ansible --version
  fi
  if command -v ansible-playbook >/dev/null 2>&1;then
    ansible-playbook --version
  fi
  if command -v ansible-galaxy >/dev/null 2>&1;then
    ansible-galaxy --version
  fi

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
  if command -v dnf >/dev/null 2>&1;then
    manager=dnf
  else
    manager=yum
  fi
  $manager clean all -y
  $manager makecache -y
  $manager remove ansible ansible-base ansible-core -y -q ||true
  # repeat code from kickstart
  $manager install -y chrony mc curl wget yum-utils openssh-server openssh-clients openssh kernel-devel kernel-headers make patch gcc
  case "$VERSION_ID" in
  "9")
    echo "Found os: $OS and release: $VERSION_ID"
    $manager install ca-certificates python3 python3-devel python3-pip krb5-devel krb5-workstation -y
    $manager install python3-setuptools python3-psutil -y ;;
   *)
    echo "Found os: $OS and release: $VERSION_ID"
    $manager install ca-certificates python3 python3-devel python3-pip python3-wheel krb5-devel krb5-workstation -y
    $manager install python3-setuptools python3-psutil -y ;;
  esac
  /usr/bin/python3 -m pip install --upgrade setuptools-rust
  install_ansible
  check_ansible
fi

if [ "$INSTALL" == "false" ] && [[ "$OS" =~ rhel|centos|fedora ]];then
  echo "Removing ansible on RHEL/related"
  if command -v dnf >/dev/null 2>&1;then
    manager=dnf
  else
    manager=yum
  fi
  $manager clean all -y
  $manager makecache -y
  /usr/bin/python3 -m pip uninstall jmespath jsonlint yamllint ansible-core ansible setuptools-rust pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp -y
  rm -rf /root/.ansible||true
  rm -rf /root/.cache||true
  rm -rf /home/vagrant/.ansible||true
  rm -rf /home/vagrant/.cache||true
  $manager clean -y all
fi

if [ "$INSTALL" == "true" ] && [[ "$OS" =~ debian|ubuntu ]];then
  echo "Installing ansible on Ubuntu/Debian"
  add_path
  apt-get clean all -y
  apt-get update -y
  apt-get purge ansible ansible-base ansible-core -y||true
  # repeat code from cloud-init
  apt-get install -y mc curl wget sudo tar bzip2 build-essential linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual net-tools
  apt-get install -y ca-certificates python3 python3-dev python3-pip python3-wheel libkrb5-dev
  install_ansible
  check_ansible
fi

if [ "$INSTALL" == "false" ] && [[ "$OS" =~ debian|ubuntu ]];then
  echo "Removing ansible on Ubuntu/Debian"
  apt-get clean all -y
  apt-get update -y
  /usr/bin/python3 -m pip uninstall jmespath jsonlint yamllint ansible-core ansible pywinrm requests-kerberos requests-ntlm requests-credssp pypsrp -y
  rm -rf /root/.ansible||true
  rm -rf /root/.cache||true
  rm -rf /home/vagrant/.ansible||true
  rm -rf /home/vagrant/.cache||true
fi
