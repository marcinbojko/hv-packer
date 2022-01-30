iso_url="https://ubuntu.man.lodz.pl/ubuntu-releases/20.04.3/ubuntu-20.04.3-live-server-amd64.iso"
iso_checksum_type="sha256"
iso_checksum="f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
vm_name="packer-ubuntu2004-g2"
disk_size="70000"
disk_additional_size=["150000"]
switch_name="vSwitch"
output_directory="output-ubuntu2004"
output_vagrant="./vbox/packer-ubuntu2004-g2.box"
vlan_id=""
vagrantfile_template="./vagrant/hv_ubuntu2004_g2.template"
ssh_password="password"
provision_script_options="-z false"
boot_command=["<esc><wait3>",
"linux /casper/vmlinuz quiet autoinstall net.ifnames=0 biosdevname=0 ip=dhcp ipv6.disable=1 ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ <enter>",
"initrd /casper/initrd <enter>",
"boot <enter>"
]
