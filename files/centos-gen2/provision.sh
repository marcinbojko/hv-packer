#!/bin/bash
# generic - basic repositories and basic stuff
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
yum -y clean all
yum -y makecache fast
yum -y update all
yum -y install epel-release
yum -y install yum-priorities yum-utils yum-cron
yum -y install mc wget curl
yum-config-manager -y --enable epel --setopt="epel.priority=60"
yum -y update all
yum clean all
rm -rf /var/cache/yum
# disable selinux
sed -i /etc/sysconfig/selinux -r -e 's/^SELINUX=.*/SELINUX=disabled/g'
sed -i /etc/selinux/config -r -e 's/^SELINUX=.*/SELINUX=disabled/g'
# webmin repository
if [ -f /tmp/webmin.repo ]; then
    mv /tmp/webmin.repo /etc/yum.repos.d/webmin.repo
fi
# zabbix
yum -y install http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
yum-config-manager -y --disable zabbix-non-supported
yum-config-manager -y --enable zabbix --setopt="zabbix.priority=20"
yum -y install zabbix-agent

# webmin
wget http://www.webmin.com/jcameron-key.asc && rpm --import jcameron-key.asc && rm jcameron-key.asc -f
yum -y makecache fast
yum-config-manager -y --enable webmin --setopt="webmin.priority=20"
yum -y install webmin

# puppet
yum -y install https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum-config-manager -y --enable puppetlabs-products --setopt="puppetlabs-products.priority=10"
yum-config-manager -y --enable puppetlabs-deps --setopt="puppetlabs-deps.priority=10"
yum -y install puppet-agent
systemctl stop puppet
systemctl disable puppet
if [ -d /etc/puppetlabs/puppet/ssl ]; then
    rm -rf /etc/puppetlabs/puppet/ssl
fi

if [ -f /tmp/puppet.conf ]; then
    mv /tmp/puppet.conf /etc/puppetlabs/puppet/puppet.conf
fi
# misc
timedatectl set-timezone Europe/Copenhagen --no-ask-password
yum -y groupinstall "X Window System"
yum -y install htop atop iftop iotop killall nmap realmd samba nmon samba-common oddjob oddjob-mkhomedir sssd ntpdate ntp adcli krb5-workstation sssd-libwbclient
yum -y install jq
yum -y install firefox gparted
yum -y install ftp://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/s/screenfetch-3.8.0-2.fc27.noarch.rpm
if [ -f /tmp/motd.sh ]; then
    mv /tmp/motd.sh /etc/profile.d/motd.sh
    chmod +x /etc/profile.d/motd.sh
fi

# hyper-v daemons
yum -y install hyperv-daemons
systemctl enable hypervfcopyd
systemctl enable hypervkvpd
systemctl enable hypervvssd

# firewalld
yum -y install firewalld
systemctl start firewalld
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="22" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="10000" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="10050-10052" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="8140" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --permanent --remove-service=ssh --zone=work
firewall-cmd --remove-service=ssh --zone-work
firewall-cmd --set-default-zone=work
firewall-cmd --permanent --zone=work --add-interface=eth0
firewall-cmd --reload

# systemd -enable and disable services
systemctl enable webmin
systemctl enable firewalld
systemctl enable ntp
systemctl set-default multi-user.target

# almost done
yum clean all
yum -y update all
package-cleanup --oldkernels --count=2
yum clean all
rm -rf /var/cache/yum