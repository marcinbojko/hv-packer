
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

variable "output_vagrant" {
  type    = string
  default = ""
}

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

variable "vagrantfile_template" {
  type    = string
  default = ""
}

variable "upgrade_timeout" {
  type    = string
  default = ""
}

variable "vagrant_sysprep_unattended" {
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
  boot_command          = ["a<enter><wait>a<enter><wait>a<enter><wait>a<enter>"]
  boot_wait             = "1s"
  communicator          = "winrm"
  cpus                  = 4
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 2
  guest_additions_mode  = "disable"
  iso_checksum          = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url               = "${var.iso_url}"
  memory                = 4096
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
    script            = "./extra/scripts/phase-1.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "1h"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./extra/scripts/phase-2.ps1"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./extra/scripts/phase-3.ps1"
  }

  provisioner "windows-restart" {
    pause_before          = "30s"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout       = "2h"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./extra/scripts/phase-4.windows-updates.ps1"
  }

  provisioner "windows-restart" {
    pause_before          = "30s"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout       = "2h"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    inline            = ["Write-Host \"Pausing before next stage\";Start-Sleep -Seconds ${var.upgrade_timeout}"]
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    pause_before      = "30s"
    script            = "./extra/scripts/phase-4.windows-updates.ps1"
  }

  provisioner "windows-restart" {
    pause_before          = "30s"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout       = "2h"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    inline            = ["Write-Host \"Pausing before next stage\";Start-Sleep -Seconds ${var.upgrade_timeout}"]
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    pause_before      = "30s"
    script            = "./extra/scripts/phase-4.windows-updates.ps1"
  }

  provisioner "windows-restart" {
    pause_before          = "30s"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout       = "2h"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    inline            = ["Write-Host \"Pausing before next stage\";Start-Sleep -Seconds ${var.upgrade_timeout}"]
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./extra/scripts/phase-5a.software.ps1"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./extra/scripts/phase-5d.windows-compress.ps1"
  }

  provisioner "powershell" {
    inline = ["Write-Output Phase-5-Deprovisioning", "if( Test-Path $Env:SystemRoot\\windows\\system32\\Sysprep\\unattend.xml ){ rm $Env:SystemRoot\\windows\\system32\\Sysprep\\unattend.xml -Force}", "& $Env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /shutdown /quiet"]
  }

}
