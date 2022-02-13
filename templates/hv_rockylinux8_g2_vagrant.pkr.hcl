
variable "ansible_override" {
  type    = string
  default = ""
}

variable "boot_command" {
  type    = string
  default = ""
}

variable "disk_size" {
  type    = string
  default = "70000"
}

variable "disk_additional_size" {
  type    = list(number)
  default = ["1024"]
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "iso_checksum" {
  type    = string
  default = ""
}

variable "iso_checksum_type" {
  type    = string
  default = ""
}

variable "iso_url" {
  type    = string
  default = ""
}

variable "output_directory" {
  type    = string
  default = ""
}
variable "provision_script_options" {
  type    = string
  default = ""
}
variable "output_vagrant" {
  type    = string
  default = ""
}
variable "ssh_password" {
  type    = string
  default = ""
  sensitive = true
}

variable "switch_name" {
  type    = string
  default = ""
}
variable "vagrantfile_template" {
  type    = string
  default = ""
}
variable "vlan_id" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}

source "hyperv-iso" "vm" {
  boot_command          = ["${var.boot_command}"]
  boot_wait             = "5s"
  communicator          = "ssh"
  cpus                  = "${var.cpus}"
  disk_block_size       = "1"
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 2
  guest_additions_mode  = "disable"
  http_directory        = "./extra/files"
  iso_checksum          = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url               = "${var.iso_url}"
  memory                = "${var.memory}"
  output_directory      = "${var.output_directory}-vgr"
  shutdown_command      = "echo 'password' | sudo -S shutdown -P now"
  shutdown_timeout      = "30m"
  ssh_password          = "${var.ssh_password}"
  ssh_timeout           = "4h"
  ssh_username          = "root"
  switch_name           = "${var.switch_name}"
  temp_path             = "."
  vlan_id               = "${var.vlan_id}"
  vm_name               = "${var.vm_name}-vgr"
}

build {
  sources = ["source.hyperv-iso.vm"]

  provisioner "file" {
    destination = "/tmp/ansible.sh"
    source      = "extra/files/gen2-linux/ansible.sh"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["chmod +x /tmp/ansible.sh", "/tmp/ansible.sh -i true"]
    inline_shebang  = "/bin/sh -x"
  }

  provisioner "file" {
    destination = "/tmp/variables.yml"
    source      = "extra/playbooks/provision_rocky8_variables.yml"
  }

  provisioner "file" {
    destination = "/tmp/override.yml"
    source      = "${var.ansible_override}"
  }

  provisioner "file" {
    destination = "/tmp/prepare_neofetch.sh"
    source      = "extra/files/gen2-linux/prepare_neofetch.sh"
  }

  provisioner "ansible-local" {
    extra_arguments = ["-e", "@/tmp/variables.yml", "-e", "@/tmp/override.yml"]
    playbook_file   = "extra/playbooks/provision_centos.yaml"
  }

  provisioner "ansible-local" {
    playbook_file = "extra/playbooks/provision_vagrant.yaml"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["chmod +x /tmp/ansible.sh", "/tmp/ansible.sh -i false"]
    inline_shebang  = "/bin/sh -x"
  }

  provisioner "file" {
    destination = "/usr/local/bin/uefi.sh"
    source      = "extra/files/gen2-rockylinux8/uefi.sh"
  }

  provisioner "file" {
    destination = "/tmp/scvmmguestagent.1.0.3.1028.x64.tar"
    source      = "extra/files/scagent/1.0.3.1028/scvmmguestagent.1.0.3.1028.x64.tar"
  }

  provisioner "file" {
    destination = "/tmp/install"
    source      = "extra/files/scagent/1.0.3.1028/install.sh"
  }

  provisioner "shell" {
    execute_command   = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    expect_disconnect = true
    inline            = ["chmod +x /tmp/install", "sh /tmp/install \"$(ls /tmp/scvmm*.x64.tar)\"", "reboot"]
    inline_shebang    = "/bin/sh -x"
  }

  provisioner "file" {
    destination = "/tmp/zeroing.sh"
    source      = "extra/files/gen2-linux/zeroing.sh"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["echo Last Phase", "chmod +x /usr/local/bin/uefi.sh", "systemctl set-default multi-user.target", "/bin/rm -f /etc/ssh/*key*", "chmod +x /tmp/zeroing.sh", "/tmp/zeroing.sh", "/bin/rm -rfv /tmp/*"]
    inline_shebang  = "/bin/sh -x"
    pause_before    = "30s"
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    output               = "${var.output_vagrant}"
    vagrantfile_template = "${var.vagrantfile_template}"
  }
}
