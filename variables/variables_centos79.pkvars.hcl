iso_url="http://centos.slaskdatacenter.com/7.9.2009/isos/x86_64/CentOS-7-x86_64-Everything-2009.iso"
iso_checksum_type="sha256"
iso_checksum="689531cce9cf484378481ae762fae362791a9be078fda10e4f6977bf8fa71350"
vm_name="packer-centos79-g2"
disk_size="70000"
disk_additional_size=["150000"]
switch_name="vSwitch"
output_directory="output-centos79"
output_vagrant="./vbox/packer-centos-79-g2.box"
vlan_id=""
vagrantfile_template="./vagrant/hv_centos79_g2.template"
ssh_password="password"
boot_command="c  setparams 'kickstart' <enter> linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CentOS\\x207\\x20x\\86_64 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/gen2-centos/ks.cfg<enter> initrdefi /images/pxeboot/initrd.img<enter> boot<enter>"
ansible_override="variables/centos7.yml"