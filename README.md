# Set of packer scripts to create Hyper-V VMs

## Requirements

* packer >= `1.3.2`. Do not use packer 1.3.0/1.3.1 - [https://github.com/hashicorp/packer/issues/6733](https://github.com/hashicorp/packer/issues/6733)
* Microsoft Hyper-V Server 2016/Microsoft Windows Server 2016

## Usage

To adjust to your Hyper-V, please check variables below:

* proper VLAN (possible passing as variable `-var 'vlan_id=0'` )
* proper Hyper-V Virtual Switch name (access to Internet will be required) (possible passing as variable `-var 'switch_name=vSwitch'` )
* proper URL for ISO images in packer's template (possible passing as variable `-var 'iso_url=file.iso'` )
* proper checksum type (possible passing as variable `-var 'iso_checksum_type=sha256'` )
* proper checksum  (possible passing as variable `-var 'iso_checksum=aaaabbbbbbbcccccccddddd'` )

### Scripts

* `validate_all.sh` - validates all templates.

### Windows Machines

* all available updates will be applied (3 passes)
* latest chocolatey and packages will be installed:

  |Package|Version|
  |-------|-------|
  |puppet-agent|5.5.8|
  |conemu|latest|
  |dotnet4.7.2|latest|
  |sysinternals|latest|

* puppet agent settings will be customized (`server=foreman.spcph.local`). Please adjust it to suit your needs.

### Linux Machines

* adjust `/files/provision.sh` to modify package's versions/servers
* `neofetch` packageas default banner during after the login - change required fields you'd like to see in `provision.sh`
* latest System Center Virtual Machine Agent available (with versioning, so you always can go back)

## Templates Windows 2016

### Hyper-V Generation 2 Windows Server 2016 Standard Image

Run `hv_win2016_g2.cmd` (Windows)

#### Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

* ./extra/files/gen2-2016/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_win2016_g2.cmd` (Windows)

### Hyper-V Generation 2 Windows Server 1709 Standard Image

#### 1709 Generation 2 Prerequisites

For Generation 2 prepare `secondary1709.iso` with folder structure:

* ./extra/files/gen2-1709/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_win2016_1709_g2.cmd` (Windows)

### Hyper-V Generation 2 Windows Server 1803 Standard Image

#### 1803 Generation 2 Prerequisites

For Generation 2 prepare `secondary1803.iso` with folder structure:

* ./extra/files/gen2-1803/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_win2016_1803_g2.cmd` (Windows)

## Templates CentOS 7.x

### Hyper-V Generation 2 CentOS 7.5 Image

Run `hv_centos75_g2.cmd` (Windows)

### Warnings

* if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
* folder `./iso` should contain iso image of your Windows 2016 Server Standard (any version will be fine)
* if needed - change `iso_url` variable to a proper iso name
* packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host)
* credentials for Windows machines: Administrator/password (removed after sysprep)
* credentials for Linux machines: root/password
* for Windows based machines adjust your settings in ./scripts/phase-2.ps1
* for Linux based machines adjust your settings in ./files/gen2-centos/provision.sh and ./files/gen2-centos/puppet.conf

## Known issues

### Infamous UEFI/Secure boot WIndows implementation

During the deployment secure keys are stored in *.vmcx file and are separated from *.vhdx file. To countermeasure it - there is added extra step in a form of (`/usr/local/bin/uefi.sh`) script that will check for existence of CentOS folder in EFI and will add extra entry in UEFI.
In manual setup you can run it as a part of your deploy. In SCVMM deployment I'd recommend using `RunOnce` feature.

### When Hyper-V host has more than one interface Packer sets {{ .HTTPIP }} variable to inproper interface

No resolution so far, template needs to be changed to pass real IP address, or there should be connection between these addresses. Limiting these, end with timeout errors.

### Packer version 1.3.0/1.3.1 have bug with `windows-restart` provisioner

[https://github.com/hashicorp/packer/issues/6733](https://github.com/hashicorp/packer/issues/6733)

## About

* Marcin Bojko - marcin(at)bojko.com.pl

Work based on [https://github.com/jacqinthebox/packer-templates.git](https://github.com/jacqinthebox/packer-templates.git)
