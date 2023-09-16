# Set of Hashicorp's `Packer` templates to create Microsoft Hyper-V virtual machines

![RockyLinux](https://img.shields.io/badge/Linux-Rocky-brightgreen)
![OracleLinux](https://img.shields.io/badge/Linux-Oracle-brightgreen)
![AlmaLinux](https://img.shields.io/badge/Linux-Alma-brightgreen)
![UbuntuLinux](https://img.shields.io/badge/Linux-Ubuntu-orange)
![Windows2019](https://img.shields.io/badge/Windows-2019-blue)
![Windows2022](https://img.shields.io/badge/Windows-2022-blue)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/marcinbojko)

Consider buying me a coffee if you like my work. All donations are appreciated. All donations will be used to pay for pipeline running costs

<!-- TOC -->

- [Set of Hashicorp's Packer templates to create Microsoft Hyper-V virtual machines](#set-of-hashicorps-packer-templates-to-create-microsoft-hyper-v-virtual-machines)
  - [Requirements](#requirements)
  - [Requirements - Quick Start](#requirements---quick-start)
    - [Install packer from Chocolatey](#install-packer-from-chocolatey)
    - [Install required plugins](#install-required-plugins)
    - [Use account with Administrator privileges for Hyper-V](#use-account-with-administrator-privileges-for-hyper-v)
    - [Add firewal exclusions for TCP ports 8000-9000 default range](#add-firewal-exclusions-for-tcp-ports-8000-9000-default-range)
    - [Adjust Hyper-V settings](#adjust-hyper-v-settings)
    - [Default passwords](#default-passwords)
  - [Scripts](#scripts)
    - [Windows Machines](#windows-machines)
    - [Linux Machines](#linux-machines)
      - [Ansible Playbooks CentOS/AlmaLinux/RockyLinux/OracleLinux](#ansible-playbooks-centosalmalinuxrockylinuxoraclelinux)
  - [Usage](#usage)
    - [hv_generic.ps1 parameters](#hv_genericps1-parameters)
    - [Building Microsoft Windows](#building-microsoft-windows)
      - [Building iso files needed for provisioning](#building-iso-files-needed-for-provisioning)
      - [Examples for Windows](#examples-for-windows)
    - [Building AlmaLinux Machines](#building-almalinux-machines)
      - [Examples for AlmaLinux](#examples-for-almalinux)
    - [Building RockyLinux Machines](#building-rockylinux-machines)
      - [Examples for RockyLinux](#examples-for-rockylinux)
    - [Building OracleLinux Machines](#building-oraclelinux-machines)
      - [Examples for OracleLinux](#examples-for-oraclelinux)
    - [Building Ubuntu Machines](#building-ubuntu-machines)
      - [Examples for Ubuntu](#examples-for-ubuntu)
  - [Known issues](#known-issues)
    - [I have general problem not covered here](#i-have-general-problem-not-covered-here)
    - [I'd like to contribute](#id-like-to-contribute)
    - [Infamous UEFI/Secure boot WIndows implementation](#infamous-uefisecure-boot-windows-implementation)
    - [~~On Windows Server 2019/Windows 10 1809 image boots to fast for packer to react~~](#on-windows-server-2019windows-10-1809-image-boots-to-fast-for-packer-to-react)
    - [~~When Hyper-V host has more than one interface Packer sets {{ .HTTPIP }} variable to inproper interface~~](#when-hyper-v-host-has-more-than-one-interface-packer-sets--httpip--variable-to-inproper-interface)
    - [~~Packer version 1.3.0/1.3.1 have bug with windows-restart provisioner~~](#packer-version-130131-have-bug-with-windows-restart-provisioner)
    - [Packer won't run until VirtualSwitch is created as shared](#packer-wont-run-until-virtualswitch-is-created-as-shared)
    - [I have problem how to find a proper WIM  name in Windows ISO to pick proper version](#i-have-problem-how-to-find-a-proper-wim--name-in-windows-iso-to-pick-proper-version)
    - [On Windows machines, build break during updates phase, when update cycles are interfering with each other](#on-windows-machines-build-break-during-updates-phase-when-update-cycles-are-interfering-with-each-other)
    - [Why don't you use ansible instead of shell scripts for provisioning](#why-dont-you-use-ansible-instead-of-shell-scripts-for-provisioning)
  - [About](#about)

<!-- /TOC -->

## Requirements

- packer <=`1.9.1`. Do not use packer below 1.7.0 version. For previous packer versions use previous releases from this repository
- Microsoft Hyper-V Server 2016/2019 or Microsoft Windows Server 2016/2019 (not 2012/R2) with Hyper-V role installed as host to build your images
- firewall exceptions for `packer` http server (look down below)
- [OPTIONAL] Vagrant >= `2.3.4` - for `vagrant` version of scripts. Boxes (prebuilt) are already available here: [https://app.vagrantup.com/marcinbojko](https://app.vagrantup.com/marcinbojko)
- be aware, for 2016 - VMs are in version 8.0, for 2019 - VMs are in version 9.0. There is no way to reuse higher version in previous operating system. If you need v8.0 - build and use only VHDX.
- properly constructed virtual switch in Hyper-v allowing virtual machine to get IP from DHCP and contact Hyper-V server on mentioned packer ports. This is a must, if kickstart is reachable over the network.

## Requirements - Quick Start

### Install packer from Chocolatey

```cmd
choco install packer --version=1.9.1 -y
```

### Install required plugins

In root folder of a repository

```cmd
packer init --upgrade config.pkr.hcl
```

<!-- ### Install vagrant from Chocolatey

```cmd
choco install vagrant --version=2.3.4 -y
``` -->

### Use account with Administrator privileges for Hyper-V

### Add firewal exclusions for TCP ports 8000-9000 (default range)

```powershell
Remove-NetFirewallRule -DisplayName "Packer_http_server" -Verbose
New-NetFirewallRule -DisplayName "Packer_http_server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000-9000
```

### Adjust Hyper-V settings

To adjust to your Hyper-V, please check variables below and/or in ./variables files

- (variable `vlan_id` in /variables/variables.*.pkvars.hcl) - proper VLAN ID . Look up to find your build server vEthernet setings.
- (variable `switch_name` in /variables/variables.*.pkvars.hcl) - proper Hyper-V Virtual Switch name (access to Internet will be required). Make sure you're using pre-existing switch in your Hyper-V server - creation of new switch by packer, instead of reusing existing one can cause lack of Internet access, thus failing the build.

```yaml
# example of mentioned variables
vlan_id = ""
switch_name = "vSwitch"
```

### Default passwords

|OS|username|password|
|--|--------|--------|
|Windows|Administrator|password|
|CentOS/RHEL|root|password|
|Ubuntu|ubuntu|password|
|||

## Scripts

### Windows Machines

- all available updates will be applied (3 passes)
- latest version of chocolatey
- packages from a list below:

  |Package|Version|Mandatory/Optional|
  |-------|-------|------------------|
  |dotnetfx|latest|Mandatory|
  |sysinternals|latest|Mandatory|
  |tabby|latest|Optional|

- `phase3.ps1` Puppet agent settings will be customized (`server=foreman.example.com`) with parameters:
  - `Version` - puppet chocolatey version, for example "6.26.0"
  - `AddPrivateChoco` ($true/$false) - if set to true, private MyGet repository will be added as `public`
  - `PuppetMaster` (foreman.example.com) - if set, in `puppet.conf` section server will point to that variable

  Example of usage:

  `.\phase3.ps1 -Version 7.14.0 -AddPrivateChoco $true -PuppetMaster foreman.example.com`

  Puppet is set to clear any temp SSL keys and to be stopped after generalize phase

- `phase5b-docker.ps1` - Docker settings can be customised
  - `requiredVersion` - which version of docker module to install - defaults to 19.03.1
  - `installCompose` ($true/$false) - install docker-compose from chocolatey packages
  - `dockerLocation` - of set, will default docker images and settings there. On empty, docker location is not being set.
  - `configDockerLocation` - default place for docker's config file

  Example of usage

  `.\phase5b-docker.ps1 -requiredVersion "19.03.1" -installCompose $true -dockerLocation "d:\docker" -configDockerLocation "C:\ProgramData\Docker\config"`

### Linux Machines

- Repositories:

  |Repository|Package|switch|default
  |----------|------------|---|---|
  |Epel 7/8/9|epel-release|can be switched off by setting "install_epel" to `false`|true|
  |Zabbix 6.0|zabbix-agent|can be switched on by setting "install_zabbix" to `true`|false|
  |Puppet 7  |puppet-agent|can be switched off by setting "install_puppet" to false|false|
  |Webmin |webmin|can be switched on by setting "install_webmin" to `false`|false|
  |Cockpit |cockpit|can be switched on by setting "install_zabbix" to `true`|true|
  |Hyper-V |SCVMM Agent|can be switched off by setting "install_hyperv" to `false`|true|
  |Neofetch  |neofetch|can be switched off by setting "install_neofetch" to `false`|true|
  ||||

  Be aware, turning off latest System Center Virtual Machine Agent will cause System Center fail to deploy machines

#### Ansible Playbooks (CentOS/AlmaLinux/RockyLinux/OracleLinux)

During deployment ansible-base and ansible are installed in operating system. After deployment ends, these packages are removed.
Playbooks are held in `/extra/playbooks` folder, with proper OS variables.

- adjust `./variables/*.yml` files to achieve override for ansible

```yaml
install_epel:                  true  # install Epel
install_webmin:                true  # install Webmin
install_hyperv:                true  # install Hyper-v and scvmm agent
install_zabbix:                false # install Zabbix-agent
install_zabbix_as_root:        false # install Zabbix-agent as root
install_cockpit:               false # install Cockpit
install_puppet:                true  # Install Puppet
install_docker_workaround:     true  # add `fsck.repair=yes` to grub
install_kubernetes_workaround: false # add `cgroup.memory=nokmem` to grub
remove_puppet_ssl_keys:        false # remove any ssl keys after puppet installation
install_neofetch:              true  # install neofetch
install_updates:               true  # install updates
install_extra_groups:          true  # install extra groups
docker_prepare:                false # prepare extra volumen for docker
extra_device:                  ""    # prepare mkfs and mount extra block device for docker
install_motd:                  true  # install motd (neofetch run)
```

## Usage

Building machines is realised through a dedicated script `hv_generic.ps1` with proper parameters.

### `hv_generic.ps1` parameters

### Building Microsoft Windows

#### Building iso files needed for provisioning

For Generation 2 prepare `secondary.iso` with folder structure:

```example
- ./extra/files/windows/2022/std/Autounattend.xml     => /Autounattend.xml
- ./extra/scripts/hyper-v/bootstrap.ps1            => /bootstrap.ps1
```

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2022 SERVERSTANDARD</Value>
    </MetaData>
</InstallFrom>
```

|Action|Version|Template|Log|OS|
|-------|-------|--------|---|-|
|`build`|windows_server_2019_std|windows|0/1|Microsoft Server 2019 Standard|
|`build`|windows_server_2019_dc|windows|0/1|Microsoft Server 2019 Datacenter|
|`build`|windows_server_2022_std|windows|0/1|Microsoft Server 2022 Standard|
|`build`|windows_server_2022_dc|windows|0/1|Microsoft Server 2022 Datacenter|

#### Examples for Windows

```powershell

Example for Windows 2019 Standard

```powershell
./hv_generic.ps1 -Action build -Version windows_server_2019_std -Template windows -Log 0
```

Example for Windows 2019 Datacenter

```powershell
./hv_generic.ps1 -Action build -Version windows_server_2019_dc -Template windows -Log 0
```

Example for Windows 2022 Standard

```powershell
./hv_generic.ps1 -Action build -Version windows_server_2022_std -Template windows -Log 0
```

Example for Windows 2022 Datacenter

```powershell
./hv_generic.ps1 -Action build -Version windows_server_2022_dc -Template windows -Log 0
```

### Building AlmaLinux Machines

|Action|Version|Template|Log|OS|
|-------|-------|--------|---|-|
|`build`|almalinux-8.8|rhel|0/1|Alma Linux 8.8|
|`build`|almalinux-9.2|rhel|0/1|Alma Linux 9.2|

#### Examples for AlmaLinux

```powershell
.\hv_generic.ps1 -Action build -Version almalinux-8.8 -Template rhel -Log 0
.\hv_generic.ps1 -Action build -Version almalinux-9.2 -Template rhel -Log 0
```

### Building RockyLinux Machines

|Action|Version|Template|Log|OS|
|-------|-------|--------|---|-|
|`build`|rockylinux-8.8|rhel|0/1|Rocky Linux 8.8|
|`build`|rockyinux-9.2|rhel|0/1|Rocky Linux 9.2|

#### Examples for RockyLinux

```powershell
.\hv_generic.ps1 -Action build -Version rockylinux-8.8 -Template rhel -Log 0
.\hv_generic.ps1 -Action build -Version rockylinux-9.2 -Template rhel -Log 0
```

### Building OracleLinux Machines

|Action|Version|Template|Log|OS|
|-------|-------|--------|---|-|
|`build`|oraclelinux-8.8|rhel|0/1|Oracle Linux 8.8|
|`build`|oraclelinux-9.2|rhel|0/1|Oracle Linux 9.2|

#### Examples for OracleLinux

```powershell
.\hv_generic.ps1 -Action build -Version oraclelinux-8.8 -Template rhel -Log 0
.\hv_generic.ps1 -Action build -Version oraclelinux-9.2 -Template rhel -Log 0
```

### Building Ubuntu Machines

|Action|Version|Template|Log|OS|
|-------|-------|--------|---|-|
|`build`|ubuntu-20.04|ubuntu|0/1|Ubuntu 20.04|
|`build`|ubuntu-22.04|ubuntu|0/1|Ubuntu 22.04|

#### Examples for Ubuntu

```powershell
.\hv_generic.ps1 -Action build -Version ubuntu-20.04 -Template ubuntu -Log 0
.\hv_generic.ps1 -Action build -Version ubuntu-22.04 -Template ubuntu -Log 0
```

## Known issues

### I have general problem not covered here

Please create an issue in github. There is slim chance I'll find the time to be your personal helpdesk ;)

### I'd like to contribute

Sure. If I can ask - create your PR in smaller sizes, this is repo used for my work, so smaller changes - bigger chances to succeed.

### Infamous UEFI/Secure boot WIndows implementation

During the deployment secure keys are stored in `*.vmcx` file and are separated from `*.vhdx` file. To countermeasure it - there is added extra step in a form of (`/usr/local/bin/uefi.sh`) script that will check for existence of CentOS folder in EFI and will add extra entry in UEFI.
In manual setup you can run it as a part of your deploy. In SCVMM deployment I'd recommend using `RunOnce` feature.

### ~~On Windows Server 2019/Windows 10 1809 image boots to fast for packer to react~~

[https://github.com/hashicorp/packer/issues/7278#issuecomment-468492880](https://github.com/hashicorp/packer/issues/7278#issuecomment-468492880)

Fixed in version 1.4.4.  Do not use previous versions

### ~~When Hyper-V host has more than one interface Packer sets {{ .HTTPIP }} variable to inproper interface~~

Fixed in version 1.4.4. Do not use lower versions
~~No resolution so far, template needs to be changed to pass real IP address, or there should be connection between these addresses. Limiting these, end with timeout errors.**~~

### ~~Packer version 1.3.0/1.3.1 have bug with `windows-restart` provisioner~~

[https://github.com/hashicorp/packer/issues/6733](https://github.com/hashicorp/packer/issues/6733)

### Packer won't run until VirtualSwitch is created as shared

[https://github.com/hashicorp/packer/issues/5023](https://github.com/hashicorp/packer/issues/5023)
Will be fixed in 1.4.x revision

### I have problem how to find a proper WIM  name in Windows ISO to pick proper version

You can use number. If you have 4 images on the list of choice - use `ImageIndex` with proper `Value`

```xml
<ImageInstall>
    <OSImage>
        <InstallFrom>
            <MetaData wcm:action="add">
                <Key>/IMAGE/INDEX </Key>
                <Value>2</Value>
            </MetaData>
        </InstallFrom>
        <InstallTo>
            <DiskID>0</DiskID>
            <PartitionID>2</PartitionID>
        </InstallTo>
    </OSImage>
</ImageInstall>
```

### On Windows machines, build break during updates phase, when update cycles are interfering with each other

Increase variable  `update_timeout` in `./variables/*.json` file - this will create longer pauses between stages, allowing cycles to complete before jumping to another one.

### Why don't you use ansible instead of shell scripts for provisioning

I wish. In short - Windows. These builds should be done with minimum effort (Hyper-V role is enough). Building custom ansible station with lots of checks right now fails in my tryouts.

## Support me

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/marcinbojko)

Consider buying me a coffee if you like my work. All donations are appreciated. All donations will be used to pay for pipeline running costs

## About

- Marcin Bojko - marcin(at)bojko.com.pl
- [https://marcinbojko.dev/](https://marcinbojko.dev/)

Work based on [https://github.com/jacqinthebox/packer-templates.git](https://github.com/jacqinthebox/packer-templates.git)
