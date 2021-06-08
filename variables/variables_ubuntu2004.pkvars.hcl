iso_url="https://ftp.icm.edu.pl/pub/Linux/ubuntu-releases/20.04.2.0/ubuntu-20.04.2-live-server-amd64.iso"
iso_checksum_type="sha256"
iso_checksum="d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"
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
