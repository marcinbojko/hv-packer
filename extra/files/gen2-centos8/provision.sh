#!/bin/bash
INSTALL_UPDATES=true
INSTALL_PUPPET=true
INSTALL_HYPERV=true
INSTALL_COCKPIT=true
INSTALL_ZABBIX=true
STAMP_FILE="/etc/packerinfo"

usage() { echo "Usage: $0 [-u <true|false> INSTALL_UPDATES ] [-p <true|false> INSTALL_PUPPET] [-w <true|false> INSTALL_COCKPIT] [-h <true|false> INSTALL_HYPERV]  [-z <true|false> INSTALL_ZABBIX]" 1>&2; }

while getopts :u:p:h:w:  option
    do
      case "${option}"
      in
      u)
        INSTALL_UPDATES="${OPTARG}"
        ;;
      p)
        INSTALL_PUPPET="${OPTARG}"
        ;;
      h)
        INSTALL_HYPERV="${OPTARG}"
        ;;
      w)
        INSTALL_COCKPIT="${OPTARG}"
        ;;
      z)
        INSTALL_ZABBIX="${OPTARG}"
        ;;
      *)
        usage
        ;;
      esac
    done
echo "INSTALL_UPDATES = $INSTALL_UPDATES"
echo "INSTALL_COCKPIT = $INSTALL_COCKPIT"
echo "INSTALL_HYPERV  = $INSTALL_HYPERV"
echo "INSTALL_PUPPET  = $INSTALL_PUPPET"
echo "INSTALL_ZABBIX  = $INSTALL_ZABBIX"

# generic - basic repositories and basic stuff
echo "Provisioning phase 1 - Starting: EPEL, SELinux and basic packages"
if [ -d /etc/pki/rpm-gpg ]; then
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
fi

echo "Provisioning phase 1 - essential packages and EPEL"
dnf -y makecache
dnf -y -e 0 install mc wget curl tar bzip2 kernel-devel kernel-headers perl gcc make elfutils-libelf-devel langpacks-en glibc-all-langpacks
# set locale
localectl set-locale LANG=en_US.UTF-8
dnf -y -e 0 install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager -y -q -e 0 --set-enabled PowerTools
dnf config-manager -y -q -e 0 --set-enabled epel
dnf config-manager -y -q -e 0 --set-disabled epel-debuginfo
dnf config-manager -y -q -e 0 --set-disabled epel-source
dnf config-manager -y -q -e 0 --set-disabled epel-testing
dnf config-manager -y -q -e 0 --set-disabled epel-testing-debuginfo
dnf config-manager -y -q -e 0 --set-disabled epel-testing-source
dnf config-manager -y -q -e 0 --set-disabled epel-playground
dnf config-manager -y -q -e 0 --set-disabled epel-playground-debuginfo
dnf config-manager -y -q -e 0 --set-disabled epel-playground-source

if [ "$INSTALL_UPDATES" == "true" ]; then
    echo "Provisioning phase 1 - system updates"
    dnf -y -e 0 -q update
    dnf -y -e 0 -q clean all
else
    echo "Provisioning phase 1 - skipping system updates"
fi

# disable selinux
echo "Provisioning phase 1 - disabling SELinux"
sed -i /etc/sysconfig/selinux -r -e 's/^SELINUX=.*/SELINUX=disabled/g'
sed -i /etc/selinux/config -r -e 's/^SELINUX=.*/SELINUX=disabled/g'
echo "Provisioning phase 1 - all done"
echo "Provisioning phase 2 - Starting: Cockpit, Zabbix, Puppet"

# cockpit repository
if [ "$INSTALL_COCKPIT" == "true" ]; then
  echo "Provisioning phase 2 - Cockpit"
  dnf install cockpit -y -e 0 -q
  systemctl start cockpit.socket
  systemctl enable --now cockpit.socket
  systemctl status cockpit.socket
else
  echo "Provisioning phase 2 - skipping Cockpit"
fi

# zabbix
if [ "$INSTALL_ZABBIX" == true ]; then
  echo "Provisioning phase 2 - Zabbix"
# zabbix 4.2 repository
  dnf -y -e 0 install https://repo.zabbix.com/zabbix/4.2/rhel/8/x86_64/zabbix-release-4.2-2.el8.noarch.rpm
  dnf config-manager -y -q --set-disabled zabbix-non-supported
  dnf config-manager -y -q --set-enabled zabbix
  dnf -y -e 0 makecache
  dnf -y -e 0 install zabbix-agent
  systemctl enable zabbix-agent
else
  echo "Provisioning phase 2 - skipping Zabbix agent"
fi

# puppet
if [ "$INSTALL_PUPPET" == "true" ]; then

    echo "Provisioning phase 2 - Puppet Agent"
    # puppet 5.x repository
    dnf -y install https://yum.puppet.com/puppet5-release-el-8.noarch.rpm
    dnf config-manager -y -q --set-enabled puppet5
    dnf config-manager -y -q --set-disabled puppet5-source
    dnf -y -e 0 install puppet-agent
    echo "Provisioning phase 2 - Puppet Agent cleaning"
    systemctl stop puppet
    systemctl disable puppet
    if [ -d /etc/puppetlabs/puppet/ssl ]; then
        rm -rf /etc/puppetlabs/puppet/ssl
    fi

    if [ -f /tmp/puppet.conf ]; then
        mv /tmp/puppet.conf /etc/puppetlabs/puppet/puppet.conf
    fi
else
    echo "Provisioning phase 2 - Skipping Puppet agent"
fi

echo "Provisioning phase 2 - Done"
echo "Provisioning phase 3 - Starting: Extra packages, timezones, neofetch, firewalld, settings"
# misc
echo "Provisioning phase 3 - Timezone"
timedatectl set-timezone Europe/Copenhagen --no-ask-password
echo "Provisioning phase 3 - Extra Packages or groups"
dnf -y install chrony htop atop iftop iotop firewalld nmap realmd samba nmon samba-common oddjob oddjob-mkhomedir sssd adcli krb5-workstation sssd-libwbclient jq firefox gparted pv neofetch screen telnet ncdu tmux multitail neofetch rkhunter
echo "Provisioning phase 3 - RK hunter"
rkhunter --propupd
# chronyd
systemctl start chronyd
systemctl enable chronyd
systemctl status chronyd
echo "Provisioning phase 3 - MOTD"

if [ -f /tmp/motd.sh ]; then
    mv /tmp/motd.sh /etc/profile.d/motd.sh
    chmod +x /etc/profile.d/motd.sh
fi

if [ "$INSTALL_HYPERV" == "true" ]; then
  echo "Provisioning phase 3 - Hyper-V/SCVMM Daemons"
  # Hyper-v daemons
  dnf -y install hyperv-daemons
  systemctl enable hypervfcopyd
  systemctl enable hypervkvpd
  systemctl enable hypervvssd
  if [ -e /tmp/install ]; then
    cd /tmp||exit
    chmod +x /tmp/install
    /tmp/install "$(ls /tmp/scvmm*.x64.tar)"
  fi
else
  echo "Provisioning phase 3 - Skipping Hyper-V/SCVMM Daemons"
fi

echo "Provisioning phase 3 - Firewalld"
# Firewalld basic configuration.
systemctl start firewalld
firewall-cmd --permanent --zone=work --add-interface=eth0
firewall-cmd --set-default-zone=work
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="22" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --permanent --remove-service=ssh --zone=work
firewall-cmd --reload

if [ "$INSTALL_ZABBIX" == true ]; then
  echo "Phase 3 - firewalld - adding zabbix rules"
  firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="10050-10052" protocol="tcp" accept'  --permanent --zone=work
  firewall-cmd --reload
fi

if [ "$INSTALL_COCKPIT" == true ]; then
echo "Phase 3 - firewalld - adding cockpit rules"
  firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="9090" protocol="tcp" accept'  --permanent --zone=work
  firewall-cmd --reload
fi

# systemd - enable and disable services
echo "Provisioning phase 3 - Services"
systemctl enable firewalld
systemctl enable sshd
systemctl set-default multi-user.target
echo "Provisioning phase 3 - Services done"


echo "Provisioning phase 4 - Final updates and cleaning up"

if [ "$INSTALL_UPDATES" == "true" ]; then
    echo "Provisioning phase 4 - system final updates"
    dnf -y -e 0 -q update
    dnf -y -e 0 -q clean all
else
    echo "Provisioning phase 4 - skipping system final updates"
fi

# almost done
dnf -y -e 0 -q clean all
dnf remove "$(dnf repoquery --installonly --latest-limit=-2 -q)"
dnf -y -e 0 -q clean all

## Clean logs
truncate -s 0 /var/log/*.*
truncate -s 0 /var/log/**/*.*
find /var/log -type f -name '*.[0-99].gz' -exec rm {} +
rm -rfv /var/log/anaconda/*
cat /etc/centos-release
# Create STAMP_FILE
if [ -e $STAMP_FILE ]; then
  rm -rf $STAMP_FILE
  touch $STAMP_FILE
fi
echo "creationDate: $(date +%Y-%m-%d_%H:%M)" >>$STAMP_FILE
echo "Provisioning phase 4 - Done"
echo "Provisioning done - all phases"