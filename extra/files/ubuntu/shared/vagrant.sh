#!/usr/bin/env bash
# Script to manipulate vagrant user for Ubuntu distros
export DEBIAN_FRONTEND=noninteractive
echo "Executing scripts/vagrant.sh"
useradd --badnames -m -U -p "$(echo "vagrant" | openssl passwd -1 -stdin)" -s /bin/bash vagrant
echo "Executing scripts/vagrant.sh - adding password"
mkdir -p 700 /home/vagrant/.ssh
curl -sL https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
chmod -v 0600 /home/vagrant/.ssh/authorized_keys
chown -v -R vagrant:vagrant /home/vagrant/.ssh
cat > /etc/sudoers.d/vagrant << EOF_sudoers_vagrant
vagrant        ALL=(ALL)       NOPASSWD: ALL
Defaults:vagrant !requiretty
EOF_sudoers_vagrant
chmod -v 0440 /etc/sudoers.d/vagrant
/bin/sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
if [ -f /etc/pam.d/common-password.bak ]; then
  echo "Restoring original common-password"
  mv -fv /etc/pam.d/common-password.bak /etc/pam.d/common-password
  rm -rfv /etc/pam.d/*.bak
fi
echo "End of scripts/vagrant.sh"
