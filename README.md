# Set of packer templates to create Microft Hyper-V virtual machines
<!-- TOC -->

- [Set of packer templates to create Microft Hyper-V virtual machines](#set-of-packer-templates-to-create-microft-hyper-v-virtual-machines)
  - [Requirements](#requirements)
  - [Usage](#usage)
    - [Install packer from Chocolatey](#install-packer-from-chocolatey)
    - [Install vagrant from Chocolatey](#install-vagrant-from-chocolatey)
    - [Use account with Administrator privileges](#use-account-with-administrator-privileges)
    - [Add firewal exclusions for TCP ports 8000-9000 default range](#add-firewal-exclusions-for-tcp-ports-8000-9000-default-range)
    - [To adjust to your Hyper-V, please check variables below and/or in ./variables files - for](#to-adjust-to-your-hyper-v-please-check-variables-below-andor-in-variables-files---for)
  - [Scripts](#scripts)
    - [Windows Machines](#windows-machines)
    - [Linux Machines](#linux-machines)
  - [Templates Windows 2019](#templates-windows-2019)
    - [Hyper-V Generation 2 Windows Server 2019 Standard Image](#hyper-v-generation-2-windows-server-2019-standard-image)
      - [Standard Generation 2 Prerequisites](#standard-generation-2-prerequisites)
    - [Hyper-V Generation 2 Windows Server 2019 Datacenter Image](#hyper-v-generation-2-windows-server-2019-datacenter-image)
      - [Datacenter Generation 2 Prerequisites](#datacenter-generation-2-prerequisites)
  - [Templates Windows 2016](#templates-windows-2016)
    - [Hyper-V Generation 2 Windows Server 2016 Standard Image](#hyper-v-generation-2-windows-server-2016-standard-image)
      - [Standard Generation 2 Prerequisites](#standard-generation-2-prerequisites)
  - [Templates Windows Server](#templates-windows-server)
    - [Hyper-V Generation 2 Windows Server 1903 Standard Image](#hyper-v-generation-2-windows-server-1903-standard-image)
    - [Hyper-V Generation 2 Windows Server 1909 Standard Image](#hyper-v-generation-2-windows-server-1909-standard-image)
    - [Hyper-V Generation 2 Windows Server 2004 Standard Image](#hyper-v-generation-2-windows-server-2004-standard-image)
  - [Templates Ubuntu](#templates-ubuntu)
    - [Warnings - Ubuntu 20.x](#warnings---ubuntu-20x)
    - [Hyper-V Generation 2 Ubuntu 20.04 Image](#hyper-v-generation-2-ubuntu-2004-image)
  - [Templates CentOS 8.x](#templates-centos-8x)
    - [Warnings - CentOS 8](#warnings---centos-8)
    - [Hyper-V Generation 2 CentOS 8.1 Image](#hyper-v-generation-2-centos-81-image)
    - [Hyper-V Generation 2 CentOS 8.2 Image](#hyper-v-generation-2-centos-82-image)
    - [Vagrant support - CentOS 8](#vagrant-support---centos-8)
  - [Templates CentOS 7.x](#templates-centos-7x)
    - [Warnings - CentOS Docker](#warnings---centos-docker)
    - [Hyper-V Generation 2 CentOS 7.8](#hyper-v-generation-2-centos-78)
    - [Hyper-V Generation 2 CentOS 7.8 Image with extra docker volume](#hyper-v-generation-2-centos-78-image-with-extra-docker-volume)
    - [Hyper-V Generation 2 CentOS 7.9](#hyper-v-generation-2-centos-79)
    - [Hyper-V Generation 2 CentOS 7.9 Image with extra docker volume](#hyper-v-generation-2-centos-79-image-with-extra-docker-volume)
    - [Vagrant support - CentOS 7.x](#vagrant-support---centos-7x)
  - [Known issues](#known-issues)
    - [I have general problem not covered here](#i-have-general-problem-not-covered-here)
    - [I'd like to contribute](#id-like-to-contribute)
    - [Infamous UEFI/Secure boot WIndows implementation](#infamous-uefisecure-boot-windows-implementation)
    - [~~On Windows Server 2019/Windows 10 1809 image boots to fast for packer to react~~](#on-windows-server-2019windows-10-1809-image-boots-to-fast-for-packer-to-react)
    - [~~When Hyper-V host has more than one interface Packer sets {{ .HTTPIP }} variable to inproper interface~~](#when-hyper-v-host-has-more-than-one-interface-packer-sets--httpip--variable-to-inproper-interface)
    - [Packer version 1.3.0/1.3.1 have bug with windows-restart provisioner](#packer-version-130131-have-bug-with-windows-restart-provisioner)
    - [Packer won't run until VirtualSwitch is created as shared](#packer-wont-run-until-virtualswitch-is-created-as-shared)
    - [I have problem how to find a proper WIM  name in Windows ISO to pick proper version](#i-have-problem-how-to-find-a-proper-wim--name-in-windows-iso-to-pick-proper-version)
    - [On Windows machines, build break during updates phase, when update cycles are interfering with each other](#on-windows-machines-build-break-during-updates-phase-when-update-cycles-are-interfering-with-each-other)
    - [Why don't you use ansible instead of shell scripts for provisioning](#why-dont-you-use-ansible-instead-of-shell-scripts-for-provisioning)
  - [About](#about)

<!-- /TOC -->
## Requirements

- packer <=`1.6.5`. Do not use packer below 1.6.0 version. For previous packer versions use previous releases from this repository
- Microsoft Hyper-V Server 2016/2019 or Microsoft Windows Server 2016/2019 (not 2012/R2) with Hyper-V role installed as host to build your images
- firewall exceptions for `packer` http server (look down below)
- [OPTIONAL] Vagrant >= `2.2.12` - for `vagrant` version of scripts. Boxes (prebuilt) are already available here: [https://app.vagrantup.com/marcinbojko](https://app.vagrantup.com/marcinbojko)
- be aware, for 2016 - VMs are in version 8.0, for 2019 - VMs are in version 9.0. There is no way to reuse higher version in previous operating system. If you need v8.0 - build and use only VHDX.

## Usage

### Install packer from Chocolatey

```cmd
choco install packer --version=1.6.5 -y
```

### Install vagrant from Chocolatey

```cmd
choco install vagrant --version=2.2.13 -y
```

### Use account with Administrator privileges for Hyper-V

### Add firewal exclusions for TCP ports 8000-9000 (default range)

```powershell
Remove-NetFirewallRule -DisplayName "Packer_http_server" -Verbose
New-NetFirewallRule -DisplayName "Packer_http_server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000-9000

```

### To adjust to your Hyper-V, please check variables below and/or in ./variables files - for

- proper VLAN ID (possible passing as variable `-var 'vlan_id=0'` ). Look to your build server NIC setings.
- proper Hyper-V Virtual Switch name (access to Internet will be required) (possible passing as variable `-var 'switch_name=vSwitch'`). Remember - creation of new switch by packer, instead of reusing existing one can cause lack of Internet access. If it's possible substitute variable with your current switch's name.
- proper URL for ISO images in packer's template (possible passing as variable `-var 'iso_url=file.iso'` ). Be warned - using your own or different images can fail the build, as for example image index or image name used by your ISO can be different then specified by script. Look at the bottom of this Readme to read how to find or use image index.
- proper checksum type (possible passing as variable `-var 'iso_checksum_type=sha256'` )
- proper checksum  (possible passing as variable `-var 'iso_checksum=aaaabbbbbbbcccccccddddd'` )

## Scripts

### Windows Machines

- all available updates will be applied (3 passes)
- latest version of chocolatey
- packages from a list below:

  |Package|Version|
  |-------|-------|
  |conemu|latest|
  |dotnetfx|latest|
  |sysinternals|latest|

- latest Nuget poweshell module
- `phase3.ps1` Puppet agent settings will be customized (`server=foreman.spcph.local`) with parameters:
  - `Version` - puppet chocolatey version, for example "5.5.20"
  - `AddPrivateChoco` ($true/$false) - if set to true, private MyGet repository will be added as `public`
  - `PuppetMaster` (foreman.spcph.local) - if set, in `puppet.conf` section server will point to that variable

  Example of usage:

  `.\phase3.ps1 -Version 5.5.20 -AddPrivateChoco $true -PuppetMaster foreman.example.com`

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

  |Repository|Package|switch|
  |----------|------------|---|
  |Epel 7    |            |no|
  |Zabbix 4.4|zabbix-agent|can be switched off by `-z false`|
  |Puppet 5  |puppet-agent|can be switched off by `-p false`|
  |Webmin (CentOS7)|webmin|can be switched off by setting `-w false`|
  |Cockpit (CentOS8) |Cockpit|can be switched off by setting `-c false`|
  |-         |scvmmagent| can be switched off by setting `-h false`|
  |neofetch  |neofetch|no|

- [Optional] Linux machine with separated disk for docker
- [Optional] Linux machine for vagrant

  Be aware, turning off latest System Center Virtual Machine Agent will cause System Center fail to deploy machines

- adjust `/files/provision.sh` to modify package's versions/servers.
- change `"provision_script_options"` variable to:
  - -p (true/false) - switch Install Puppet on/off
  - -w (true/false) - switch Install Webmin on/off (CentOS7 only)
  - -h (true/false) - switch Install Hyper-V integration services on/off
  - -u (true/false) - switch yum update all on/off (usable when creating previous than `latest` version of OS)
  - -z (true/false) - switch Zabbix-agent installation
  - -c (true/false) - switch Cockpit installation (CentOS8 only)

  Example:

  ```json
  "provision_script_options": "-p false -u true -w true -h false -z false"
   ```

- `prepare_neofetch.sh` -  default banner during after the login - change required fields you'd like to see in `provision.sh`

## Templates Windows 2019

### Hyper-V Generation 2 Windows Server 2019 Standard Image

Run `hv_win2019_std.ps1` (Windows)

#### 2019 Standard Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

- ./extra/files/gen2-2019/std/Autounattend.xml     => /Autounattend.xml
- ./extra/scripts/hyper-v/bootstrap.ps1            => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2019 SERVERSTANDARD</Value>
    </MetaData>
</InstallFrom>
```

### Hyper-V Generation 2 Windows Server 2019 Datacenter Image

Run `hv_win2019_dc.ps1` (Windows)

#### 2019 Datacenter Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

- ./extra/files/gen2-2019/dc/Autounattend.xml     => /Autounattend.xml
- ./extra/scripts/hyper-v/bootstrap.ps1            => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2019 SERVERDATACENTER</Value>
    </MetaData>
</InstallFrom>
```

## Templates Windows 2016

### Hyper-V Generation 2 Windows Server 2016 Standard Image

Run `hv_win2016_std.ps1` (Windows)

#### 2016 Standard Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

- ./extra/files/gen2-2016/Autounattend.xml     => /Autounattend.xml
- ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2016 SERVERSTANDARD</Value>
    </MetaData>
</InstallFrom>
```

## Templates Windows Server

### Hyper-V Generation 2 Windows Server 1903 Standard Image

If you need changes For - prepare `secondary1903.iso` with folder structure:

- ./extra/files/gen2-1903/Autounattend.xml     => /Autounattend.xml
- ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_winserver_1903.ps1`

### Hyper-V Generation 2 Windows Server 1909 Standard Image

If you need changes For - prepare `secondary1909.iso` with folder structure:

- ./extra/files/gen2-1909/Autounattend.xml     => /Autounattend.xml
- ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_winserver_1909.ps1`

### Hyper-V Generation 2 Windows Server 2004 Standard Image

If you need changes For - prepare `secondary2004.iso` with folder structure:

- ./extra/files/gen2-2004/Autounattend.xml     => /Autounattend.xml
- ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_winserver_2004.ps1`

## Templates Ubuntu

### Warnings - Ubuntu 20.x

- if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
- if needed - change `iso_url` variable to a proper iso name
- packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host) and v9 for Windows Server 2019/Windows 10 1809
- credentials for Windows machines: Administrator/password (removed after sysprep)
- credentials for Linux machines: root/password
- for Windows based machines adjust your settings in ./scripts/phase-2.ps1
- for Linux based machines adjust your settings in ./files/gen2-{{os}}/provision.sh and ./files/gen2-{{os}}/puppet.conf

### Hyper-V Generation 2 Ubuntu 20.04 Image

Run `hv_ubuntu2004.ps1`

## Templates CentOS 8.x

### Warnings - CentOS 8

- if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
- if needed - change `iso_url` variable to a proper iso name
- packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host) and v9 for Windows Server 2019/Windows 10 1809
- credentials for Windows machines: Administrator/password (removed after sysprep)
- credentials for Linux machines: root/password
- for Windows based machines adjust your settings in ./scripts/phase-2.ps1
- for Linux based machines adjust your settings in ./files/gen2-centos/provision.sh and ./files/gen2-centos/puppet.conf

### Hyper-V Generation 2 CentOS 8.1 Image

Run `hv_centos81.ps1`

### Hyper-V Generation 2 CentOS 8.2 Image

Run `hv_centos82.ps1`

### Vagrant support - CentOS 8

Experimental support for vagrant machines `hv_centos81_vagrant.ps1` for CentOS 8.1
Experimental support for vagrant machines `hv_centos82_vagrant.ps1` for CentOS 8.2

## Templates CentOS 7.x

### Warnings - CentOS Docker

- if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
- if needed - change `iso_url` variable to a proper iso name
- packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host) and v9 for Windows Server 2019/Windows 10 1809
- credentials for Windows machines: Administrator/password (removed after sysprep)
- credentials for Linux machines: root/password
- for Windows based machines adjust your settings in ./scripts/phase-2.ps1
- for Linux based machines adjust your settings in ./files/gen2-centos/provision.sh and ./files/gen2-centos/puppet.conf
- no `docker` repo will be added  and no `docker-related` packages will be installed - this build creates and mount separated volume (size specified by variable) for docker

### Hyper-V Generation 2 CentOS 7.8

Run `hv_centos78_docker.ps1`

### Hyper-V Generation 2 CentOS 7.8 Image with extra docker volume

Run `hv_centos78_docker.ps1`

### Hyper-V Generation 2 CentOS 7.9

Run `hv_centos79_docker.ps1`

### Hyper-V Generation 2 CentOS 7.9 Image with extra docker volume

Run `hv_centos79_docker.ps1`

### Vagrant support - CentOS 7.x

Experimental support for vagrant machines `hv_centos78_vagrant.ps1` for CentOS 7.8
Experimental support for vagrant machines `hv_centos79_vagrant.ps1` for CentOS 7.9

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

Fixed in version 1.4.4.  Do not use lower versions

### ~~When Hyper-V host has more than one interface Packer sets {{ .HTTPIP }} variable to inproper interface~~

Fixed in version 1.4.4. Do not use lower versions
~~No resolution so far, template needs to be changed to pass real IP address, or there should be connection between these addresses. Limiting these, end with timeout errors.**~~

### Packer version 1.3.0/1.3.1 have bug with `windows-restart` provisioner

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

## About

- Marcin Bojko - marcin(at)bojko.com.pl
- [https://marcinbojko.dev/](https://marcinbojko.dev/)

Work based on [https://github.com/jacqinthebox/packer-templates.git](https://github.com/jacqinthebox/packer-templates.git)
