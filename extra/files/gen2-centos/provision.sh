#!/bin/bash
# generic - basic repositories and basic stuff
echo "Provisioning phase 1 - EPEL, SELinux and basic packages"
if [ -d /etc/pki/rpm-gpg ]; then
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
fi

yum -y makecache fast
yum -y -e 0 install epel-release yum-priorities yum-utils yum-cron mc wget curl
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
yum -y -e 0 install http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
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
curl -o /etc/yum.repos.d/konimex-neofetch-epel-7.repo https://copr.fedorainfracloud.org/coprs/konimex/neofetch/repo/epel-7/konimex-neofetch-epel-7.repo
yum -y install htop atop iftop iotop firewalld bmon nmap realmd samba nmon samba-common oddjob oddjob-mkhomedir sssd ntpdate ntp adcli krb5-workstation sssd-libwbclient jq firefox gparted pv neofetch screen

if [ -f /tmp/motd.sh ]; then
    mv /tmp/motd.sh /etc/profile.d/motd.sh
    chmod +x /etc/profile.d/motd.sh
fi

# Create neofetch entries
config="/etc/neofetch/config.conf"

if [ -e $config ]; then
  # comment
  sed -i -e 's/^[[:blank:]]*info "Packages" packages/#info "Packages" packages/g' $config
  sed -i -e 's/^[[:blank:]]*info "Resolution" resolution/#info "Resolution" resolution/g' $config
  sed -i -e 's/^[[:blank:]]*info "DE" de/#info "DE" de/g' $config
  sed -i -e 's/^[[:blank:]]*info "WM" wm/#info "WM" wm/g' $config
  sed -i -e 's/^[[:blank:]]*info "WM Theme" wm_theme/#info "WM Theme" wm_theme/g' $config
  sed -i -e 's/^[[:blank:]]*info "Theme" theme/#info "Theme" theme/g' $config
  sed -i -e 's/^[[:blank:]]*info "Icons" icons/#info "Icons" icons/g' $config
  sed -i -e 's/^[[:blank:]]*info "Terminal" term/#info "Terminal" term/g' $config
  sed -i -e 's/^[[:blank:]]*info "Terminal Font" term_font/#info "Terminal Font" term_font/g' $config
  # uncomment
  sed -i -e 's/^[[:blank:]]*# info "Disk" disk/info "Disk" disk/g' $config
  sed -i -e 's/^[[:blank:]]*# info "Local IP" local_ip/info "Local IP" local_ip/g' $config
else
 echo "File doesn't exist"
fi
# end of neofetch entries

# hyper-v daemons
yum -y install hyperv-daemons
systemctl enable hypervfcopyd
systemctl enable hypervkvpd
systemctl enable hypervvssd

# firewalld
systemctl start firewalld
firewall-cmd --permanent --zone=work --add-interface=eth0
firewall-cmd --set-default-zone=work
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="22" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="10000" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="10050-10052" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --add-rich-rule 'rule family="ipv4" source address="0.0.0.0/0" port port="8140" protocol="tcp" accept'  --permanent --zone=work
firewall-cmd --permanent --remove-service=ssh --zone=work
firewall-cmd --reload

# systemd -enable and disable services
chkconfig webmin on
systemctl enable firewalld
systemctl enable ntpd
systemctl set-default multi-user.target

echo "Provisioning phase 4 - Final updates and cleaning up"
# almost done
yum -y -e 0 -q clean all
yum -y -e 0 update
package-cleanup --oldkernels --count=2
yum -y -e 0 -q clean all
rm -rf /var/cache/yum
