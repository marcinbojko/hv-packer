#!/bin/bash
INSTALL_UPDATES=true
INSTALL_PUPPET=true
INSTALL_HYPERV=true
INSTALL_WEBMIN=true
STAMP_FILE="/etc/packerinfo"

usage() { echo "Usage: $0 [-u <true|false> INSTALL_UPDATES ] [-p <true|false> INSTALL_PUPPET] [-w <true|false> INSTALL_WEBMIN] [-h <true|false> INSTALL_HYPERV] " 1>&2; }

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
        INSTALL_WEBMIN="${OPTARG}"
        ;;
      *)
        usage
        ;;
      esac
    done
echo "INSTALL_UPDATES = $INSTALL_UPDATES"
echo "INSTALL_WEBMIN  = $INSTALL_WEBMIN"
echo "INSTALL_HYPERV  = $INSTALL_HYPERV"
echo "INSTALL_PUPPET  = $INSTALL_PUPPET"

# generic - basic repositories and basic stuff
echo "Provisioning phase 1 - Starting: EPEL, SELinux and basic packages"
if [ -d /etc/pki/rpm-gpg ]; then
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
fi
echo "Provisioning phase 1 - essential packages and EPEL"
yum -y makecache fast
yum -y -e 0 install epel-release yum-plugin-priorities yum-utils yum-cron yum-plugin-versionlock mc wget curl
yum-config-manager -y -q -e 0 --enable epel --setopt="epel.priority=60"|grep -i "enabled ="

if [ "$INSTALL_UPDATES" == "true" ]; then
    echo "Provisioning phase 1 - system updates"
    yum -y -e 0 -q update
    yum -y -e 0 -q clean all
    rm -rf /var/cache/yum
else
    echo "Provisioning phase 1 - skipping system updates"
fi

# disable selinux
echo "Provisioning phase 1 - disabling SELinux"
sed -i /etc/sysconfig/selinux -r -e 's/^SELINUX=.*/SELINUX=disabled/g'
sed -i /etc/selinux/config -r -e 's/^SELINUX=.*/SELINUX=disabled/g'
echo "Provisioning phase 1 - all done"
echo "Provisioning phase 2 - Starting: Webmin, Zabbix, Puppet"

# webmin repository
if [ "$INSTALL_WEBMIN" == "true" ]; then
    echo "Provisioning phase 2 - Webmin"
    if [ -f /tmp/webmin.repo ]; then
        mv /tmp/webmin.repo /etc/yum.repos.d/webmin.repo
        wget http://www.webmin.com/jcameron-key.asc && rpm --import jcameron-key.asc && rm jcameron-key.asc -f
        yum-config-manager -y -q --enable webmin --setopt="webmin.priority=20"|grep -i "enabled ="
        yum -y -e 0 makecache fast
        yum -y -e 0 install webmin
    fi
else
    echo "Provisioning phase 2 - skipping Webmin"
fi

# zabbix
echo "Provisioning phase 2 - Zabbix"
# zabbix 4.2 repository
yum -y -e 0 install https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-2.el7.noarch.rpm
yum-config-manager -y -q --disable zabbix-non-supported|grep -i "enabled ="
yum-config-manager -y -q --enable zabbix --setopt="zabbix.priority=20"|grep -i "enabled ="
yum -y -e 0 makecache fast
yum -y -e 0 install zabbix-agent

# puppet
if [ "$INSTALL_PUPPET" == "true" ]; then

    echo "Provisioning phase 2 - Puppet Agent"
    # puppet 5.x repository
    yum -y install https://yum.puppet.com/puppet5-release-el-7.noarch.rpm
    yum-config-manager -y -q --enable puppetlabs-products --setopt="puppetlabs-products.priority=10"|grep -i "enabled ="
    yum-config-manager -y -q --enable puppetlabs-deps --setopt="puppetlabs-deps.priority=10"|grep -i "enabled ="
    yum -y -e 0 install puppet-agent
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
echo "Provisioning phase 3 - Timezone/Yum Groups"
timedatectl set-timezone Europe/Copenhagen --no-ask-password
yum -y groups list
yum -y groups mark install "X Window System"
# neofetch
echo "Provisioning phase 3 - Nefoetch"
curl -o /etc/yum.repos.d/konimex-neofetch.repo https://copr.fedorainfracloud.org/coprs/konimex/neofetch/repo/epel-7/konimex-neofetch-epel-7.repo
echo "Provisioning phase 3 - Extra Packages"
yum -y install htop atop iftop iotop firewalld bmon nmap realmd samba nmon samba-common oddjob oddjob-mkhomedir sssd ntpdate ntp adcli krb5-workstation sssd-libwbclient jq firefox gparted pv neofetch screen telnet ncdu tmux multitail

echo "Provisioning phase 3 - MOTD"

if [ -f /tmp/motd.sh ]; then
    mv /tmp/motd.sh /etc/profile.d/motd.sh
    chmod +x /etc/profile.d/motd.sh
fi

if [ "$INSTALL_HYPERV" == "true" ]; then
  echo "Provisioning phase 3 - Hyper-V/SCVMM Daemons"
  # Hyper-v daemons
  yum -y install hyperv-daemons
  systemctl enable hypervfcopyd
  systemctl enable hypervkvpd
  systemctl enable hypervvssd
  if [ -e /tmp/install ]; then
    cd /tmp||exit
    chmod +x /tmp/install
    /tmp/install /tmp/scvmmguestagent.1.0.3.1022.x64.tar
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
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="10000" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="10050-10052" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --permanent --remove-service=ssh --zone=work
firewall-cmd --reload

# systemd - enable and disable services
echo "Provisioning phase 3 - Services"
chkconfig webmin on
systemctl enable firewalld
systemctl enable ntpd
systemctl enable sshd
systemctl set-default multi-user.target
echo "Provisioning phase 3 - Services done"

echo "Provisioning phase 4 - Final updates and cleaning up"

if [ "$INSTALL_UPDATES" == "true" ]; then
    echo "Provisioning phase 4 - system final updates"
    yum -y -e 0 -q update
    yum -y -e 0 -q clean all
    rm -rf /var/cache/yum
else
    echo "Provisioning phase 4 - skipping system final updates"
fi

# almost done
yum -y -e 0 -q clean all
package-cleanup --oldkernels --count=2 -y
yum -y -e 0 -q clean all
rm -rf /var/cache/yum

## Clean logs
truncate -s 0 /var/log/*.*
truncate -s 0 /var/log/**/*.*
find /var/log -type f -name '*.[0-99].gz' -exec rm {} +
rm -rfv /var/log/anaconda/*
cat /etc/centos-release
# Create STAMP_FILE
if [ -e $STAMP_FILE ]; then
  rm -rfv $STAMP_FILE
  touch $STAMP_FILE
fi
echo "creationDate: $(date +%Y-%m-%d_%H:%M)" >>$STAMP_FILE
echo "Provisioning phase 4 - Done"
echo "Provisioning done - all phases"