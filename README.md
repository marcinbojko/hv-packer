# Set of packer scripts to create Hyper-V VMs

## Requirements

* packer >= `1.1.3`
* Microsoft Hyper-V Server 2016/Microsoft Windows Server 2016

## Usage

To adjust to your Hyper-V, please check variables below:

* proper VLAN (possible passing as variable `-var 'vlan_id=0'` )
* proper Hyper-V Virtual Switch name (access to Internet will be required) (possible passing as variable `-var 'switch_name=vSwitch'` )
* proper URL for ISO images in packer's template (possible passing as variable `-var 'iso_url=file.iso'` )
* proper checksum type (possible passing as variable `-var 'iso_checksum_type=sha256'` )
* proper checksum  (possible passing as variable `-var 'iso_checksum=aaaabbbbbbbcccccccddddd'` )

### Scripts

* `run_all.cmd` - runs all build tasks
* `validate_all.sh` - validates all tasks

### Windows Machines

* all available updates will be applied (3 passes)
* latest chocolatey and packages will be installed:
  * `puppet-agent`
  * `conemu`
  * `dotnet4.7`
  * `dotnet4.7.1`
  * `sysinternals`

* puppet agent settings will be customized (server=foreman.spcph.local). Please adjust it to your needs.

### Linux Machines

* adjust `/files/provision.sh` to modify package's versions/servers
* `screenfetch` as default banner during after the login
* latest System Center Virtual Machine Agent

## Templates Windows 2016

### Hyper-V Generation 1 Windows Server 2016 Standard Image

Run `hv_win2016_g1.sh`  (WSL)

Run `hv_win2016_g1.cmd` (Windows)

### Hyper-V Generation 2 Windows Server 2016 Standard Image

#### Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

* ./extra/files/gen2-2016/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_win2016_g2.sh` (WSL)

Run `hv_win2016_g2.cmd` (Windows)

### Hyper-V Generation 2 Windows Server 1709 Standard Image

#### 1709 Generation 2 Prerequisites

For Generation 2 prepare `secondary1709.iso` with folder structure:

* ./extra/files/gen2-1709/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_win2016_1709_g2.cmd` (Windows)

## Templates CentOS 7.x

### Hyper-V Generation 2 CentOS 7.4 Image

Run `hv_centos74_g2.sh`  (Linux & Mac)

Run `hv_centos74_g2.cmd` (Windows)

### Warnings

* if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
* folder `./iso` should contain iso image of your Windows 2016 Server Standard (any version will be fine)
* if needed - change `iso_url` variable to a proper iso name
* packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host)
* credentials for Windows machines: Administrator/password (removed after sysprep)
* credentials for Linux machines: root/password
* for Windows based machines adjust your settings in ./scripts/phase-2.ps1
* for Linux based machines adjust your settings in ./files/gen2-centos/provision.sh and ./files/gen2-centos/puppet.conf

## Changelog

### Version 1.0.3 2018-02-23

* `BREAKING FEATURE` - preparing switching to submodules/subtree for ./scripts and ./files - to share common code with other providers
* tree structure in `./scripts` and `./files`, moved to `./extras`
* [Windows] adding `phase-3.ps1` script to put less generic stuff there. Just uncomment line with `exit` to get rid of it
* [Windows] added support for `Windows Server 1709 Edition (Standard)`
* [Windows] remove some clutter from `bootstrap.ps1`
* [Windows] added `exit 0` for most of the scripts as some external commands were leaving packer with non-zero exit codes
* [CentOS] added `zeroing.sh` script to make compacting more efficient
* [CentOS] reworked bug with UEFI - this time after deploying from image you can run sscript `/usr/local/bin/uefi.sh` which will recheck and readd CentOS UEFI entries. For SCVMM deployments (which separates vhdx from vmcx) use `RunOnce`
* [CentOS] removed clutter from `provision.sh`
* [CentOS] removed screenfetch, replaced with neofetch
* [CentOS] reworked `motd.sh` in `/etc/profile.d` to reflect .Xauthority existence

### Version 1.0.2 2017-12-17

* workaround for PS module `PSWindowsUpdate` in Windows Templates
* added `nmon`, `jq` and `sssd-libwebclient` to CentOS 7.4 template
* added `temp_path` in templates to point creation of VMs to current script's folder
* tested with packer 1.1.3
* added variable `vlan_id`
* added variable `switch_name`
* resized OS images to 70GB (Windows)
* sector-size change in  PS cleaning script (from 64k to 4MB - double the speed)

### Version 1.0.1

* documentation fixes

### Version 1.0.0

* initial release for github

### prerelease versions

* serious bug with UEFI partitioning in CentOS 7.x generation 2 - `Unable to find \EFI\BOOT\grubx64.efi` [https://blogs.msdn.microsoft.com/virtual_pc_guy/2015/02/11/copying-the-vhd-of-a-generation-2-linux-vmand-not-booting-afterwards/](https://blogs.msdn.microsoft.com/virtual_pc_guy/2015/02/11/copying-the-vhd-of-a-generation-2-linux-vmand-not-booting-afterwards/)
* disabled libvirtd in CentOS 7.4 template
* added support for SystemCenter VMM Linux Agent for CentOS Gen 2 machines - it's required in case of per-template deployment
* changed firewalld default configuration
  * default zone set from `public` to `work`
  * default set of rules for zone 'work'
  * assigning interface `eth0` to zone `work`
  * remove excessive logging for
* changed `/etc/profile.d/motd.sh` to adjust missing XAUTHORITY variable
* made files more generic, removed company's related terms
* added adcli and krb5-workstation packages for CentOS 7.x image
* added CentOS 7.4 Gen 2 template `hv_centos74_g2`
* removed `vlan_id` and `switch_name` settings - revert to default ones for repository to be more generic.
* fixed cmd scripts with Windows current catalog syntax.
* added CentOS 7.4 Gen 2 template `hv_centos74_g2`
* removed `vlan_id` and `switch_name` settings - revert to default ones for repository to be more generic.
* fixed cmd scripts with Windows current catalog syntax.
* added `cmd` scripts for Windows deployment
* initial build

## Known issues

### Infamous UEFI/Secure boot WIndows implementation.
During the deployment secure keys are store in *.vmcx file and are separated from *.vhdx file. To countermeasure it - there is added extre step (manual) in a form of `/usr/local/bin/uefi.sh` script that will check for existence of CentOS folder in EFI and will add extra entry in UEFI.
In manual setup you can run it as a part of deploy. In SCVMM deployment I'd recommend using `RunOnce` feature.

## About

* Marcin Bojko - marcin(at)bojko.com.pl

Work based on [https://github.com/jacqinthebox/packer-templates.git](https://github.com/jacqinthebox/packer-templates.git)
