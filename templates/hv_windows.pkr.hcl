variable "memory" {
  type    = string
  default = "1024"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "disk_size" {
  type    = string
  default = ""
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

// variable "output_vagrant" {
//   type    = string
//   default = ""
// }

variable "secondary_iso_image" {
  type    = string
  default = ""
}

variable "switch_name" {
  type    = string
  default = ""
}

variable "sysprep_unattended" {
  type    = string
  default = ""
}


// variable "vagrantfile_template" {
//   type    = string
//   default = ""
// }

variable "upgrade_timeout" {
  type    = string
  default = ""
}

// variable "vagrant_sysprep_unattended" {
//   type    = string
//   default = ""
// }

variable "vlan_id" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}

source "hyperv-iso" "vm" {
  boot_command          = ["a<enter><wait>a<enter><wait>a<enter><wait>a<enter>"]
  boot_wait             = "1s"
  communicator          = "winrm"
  cpus                  = "${var.cpus}"
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 2
  guest_additions_mode  = "disable"
  iso_checksum          = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url               = "${var.iso_url}"
  memory                = "${var.memory}"
  output_directory      = "${var.output_directory}"
  secondary_iso_images  = ["${var.secondary_iso_image}"]
  shutdown_timeout      = "30m"
  skip_export           = true
  switch_name           = "${var.switch_name}"
  temp_path             = "."
  vlan_id               = "${var.vlan_id}"
  vm_name               = "${var.vm_name}"
  winrm_password        = "password"
  winrm_timeout         = "8h"
  winrm_username        = "Administrator"
}

build {
  sources = ["source.hyperv-iso.vm"]

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./extra/scripts/windows/shared/phase-1.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "1h"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./extra/scripts/windows/shared/phase-2.ps1"
  }

  provisioner "windows-restart" {
    pause_before          = "1m0s"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout       = "2h"
  }

  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    update_limit = 10
  }

  provisioner "windows-restart" {
    restart_timeout = "1h"
  }

  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    update_limit = 10
  }

  provisioner "windows-restart" {
    restart_timeout = "1h"
  }


  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./extra/scripts/windows/shared/phase-5a.software.ps1"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./extra/scripts/windows/shared/phase-5d.windows-compress.ps1"
  }

  provisioner "file" {
    destination = "C:\\Windows\\System32\\Sysprep\\unattend.xml"
    source      = "${var.sysprep_unattended}"
  }

  provisioner "powershell" {
    inline = ["Write-Output Phase-5-Deprovisioning", "if (!(Test-Path -Path $Env:SystemRoot\\system32\\Sysprep\\unattend.xml)){ Write-Output 'No file';exit (10)}", "& $Env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /shutdown /quiet /unattend:C:\\Windows\\system32\\sysprep\\unattend.xml"]
  }

}
