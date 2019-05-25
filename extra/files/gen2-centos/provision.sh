#!/bin/bash
# generic - basic repositories and basic stuff
echo "Provisioning phase 1 - EPEL, SELinux and basic packages"
if [ -d /etc/pki/rpm-gpg ]; then
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
fi

yum -y makecache fast
yum -y -e 0 install epel-release yum-priorities yum-utils yum-cron yum-plugin-versionlock mc wget curl
yum-config-manager -y -q -e 0 --enable epel --setopt="epel.priority=60"|grep -i "enabled ="
yum -y -e 0 -q update
yum -y -e 0 -q clean all
rm -rf /var/cache/yum
# disable selinux
sed -i /etc/sysconfig/selinux -r -e 's/^SELINUX=.*/SELINUX=disabled/g'
sed -i /etc/selinux/config -r -e 's/^SELINUX=.*/SELINUX=disabled/g'

echo "Provisioning phase 2 - Webmin, Zabbix, Puppet"
# webmin repository
if [ -f /tmp/webmin.repo ]; then
    mv /tmp/webmin.repo /etc/yum.repos.d/webmin.repo
fi
# zabbix
yum -y -e 0 install https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
yum-config-manager -y -q --disable zabbix-non-supported|grep -i "enabled ="
yum-config-manager -y -q --enable zabbix --setopt="zabbix.priority=20"|grep -i "enabled ="
yum -y -e 0 makecache fast
yum -y -e 0 install zabbix-agent

# webmin
wget http://www.webmin.com/jcameron-key.asc && rpm --import jcameron-key.asc && rm jcameron-key.asc -f
yum-config-manager -y -q --enable webmin --setopt="webmin.priority=20"|grep -i "enabled ="
yum -y -e 0 makecache fast
yum -y -e 0 install webmin

# puppet
yum -y install https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum-config-manager -y -q --enable puppetlabs-products --setopt="puppetlabs-products.priority=10"|grep -i "enabled ="
yum-config-manager -y -q --enable puppetlabs-deps --setopt="puppetlabs-deps.priority=10"|grep -i "enabled ="
yum -y -e 0 install puppet-agent
systemctl stop puppet
systemctl disable puppet
if [ -d /etc/puppetlabs/puppet/ssl ]; then
    rm -rf /etc/puppetlabs/puppet/ssl
fi

if [ -f /tmp/puppet.conf ]; then
    mv /tmp/puppet.conf /etc/puppetlabs/puppet/puppet.conf
fi
echo "Provisioning phase 3 - Extra packages, firewalld, settings"
# misc
timedatectl set-timezone Europe/Copenhagen --no-ask-password
yum -y groups mark install "X Window System"
# neofetch
curl -o /etc/yum.repos.d/konimex-neofetch.repo https://copr.fedorainfracloud.org/coprs/konimex/neofetch/repo/epel-7/konimex-neofetch-epel-7.repo
yum -y install htop atop iftop iotop firewalld bmon nmap realmd samba nmon samba-common oddjob oddjob-mkhomedir sssd ntpdate ntp adcli krb5-workstation sssd-libwbclient jq firefox gparted pv neofetch screen telnet ncdu tmux

if [ -f /tmp/motd.sh ]; then
    mv /tmp/motd.sh /etc/profile.d/motd.sh
    chmod +x /etc/profile.d/motd.sh
fi

# Hyper-v daemons
yum -y install hyperv-daemons
systemctl enable hypervfcopyd
systemctl enable hypervkvpd
systemctl enable hypervvssd

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
chkconfig webmin on
systemctl enable firewalld
systemctl enable ntpd
systemctl enable sshd
systemctl set-default multi-user.target

echo "Provisioning phase 4 - Final updates and cleaning up"
# almost done
yum -y -e 0 -q clean all
yum -y -e 0 update
package-cleanup --oldkernels --count=2
yum -y -e 0 -q clean all
rm -rf /var/cache/yum
## Clean logs
truncate -s 0 /var/log/*.*
truncate -s 0 /var/log/**/*.*
find /var/log -type f -name '*.[0-99].gz' -exec rm {} +
rm -rfv /var/log/anaconda/*
