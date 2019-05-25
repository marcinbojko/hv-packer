# Set of packer scripts to create Hyper-V VMs

## Requirements

* packer <=`1.4.1`. Do not use packer below 1.4.0. For previous packer versions use previous releases from this repository
* [OPTIONAL] Vagrant >= `2.2.3`
* Microsoft Hyper-V Server 2016/2019 or Microsoft Windows Server 2016/2019 (not 2012/R2)

## Usage

### Install packer from Chocolatey

```cmd
choco install packer --version=1.4.1
```

### Add firewal exclusions for TCP ports 8000-9000 (default range)

```powershell
Remove-NetFirewallRule -DisplayName "Packer_http_server" -Verbose
New-NetFirewallRule -DisplayName "Packer_http_server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000-9000

```

### To adjust to your Hyper-V, please check variables below:

* proper VLAN (possible passing as variable `-var 'vlan_id=0'` )
* proper Hyper-V Virtual Switch name (access to Internet will be required) (possible passing as variable `-var 'switch_name=vSwitch'` )
* proper URL for ISO images in packer's template (possible passing as variable `-var 'iso_url=file.iso'` )
* proper checksum type (possible passing as variable `-var 'iso_checksum_type=sha256'` )
* proper checksum  (possible passing as variable `-var 'iso_checksum=aaaabbbbbbbcccccccddddd'` )

### Scripts

* `validate_all.sh` - validates all templates.

### Windows Machines

* all available updates will be applied (3 passes)
* latest version of chocolatey
* packages from a list below:

  |Package|Version|
  |-------|-------|
  |puppet-agent|5.5.12|
  |conemu|latest|
  |dotnet4.7.2|latest|
  |sysinternals|latest|
* latest Nuget poweshell module
* puppet agent settings will be customized (`server=foreman.spcph.local`). Please adjust it (`/extra/scripts/phase-3.ps1`) to suit your needs. Puppet won't be running after generalize phase

### Linux Machines

* Repositories:
  * EPEL 7
  * Zabbix 4.x
  * Puppet 5.x
  * Webmin
  * Neofetch
* latest System Center Virtual Machine Agent available (with versioning, so you always can go back)

#### Info

* adjust `/files/provision.sh` to modify package's versions/servers
* `neofetch` packageas default banner during after the login - change required fields you'd like to see in `provision.sh`

## Templates Windows 2016

### Hyper-V Generation 2 Windows Server 2016 Standard Image

Run `hv_win2016_g2.cmd` (Windows)

#### 2016 Standard Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

* ./extra/files/gen2-2016/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2016 SERVERSTANDARD</Value>
    </MetaData>
</InstallFrom>
```

Run `hv_win2016_g2.cmd` (Windows)

### Hyper-V Generation 2 Windows Server 2019 Standard Image

Run `hv_win2019_std_g2.cmd` (Windows)

#### 2019 Standard Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

* ./extra/files/gen2-2019/std/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1            => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2019 SERVERSTANDARD</Value>
    </MetaData>
</InstallFrom>
```

Run `hv_win2019_std_g2.cmd` (Windows)

### Hyper-V Generation 2 Windows Server 2019 Datacenter Image

Run `hv_win2019_std_g2.cmd` (Windows)

#### 2019 Datacenter Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

* ./extra/files/gen2-2019/dc/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1            => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2019 SERVERDATACENTER</Value>
    </MetaData>
</InstallFrom>
```

Run `hv_win2019_dc_g2.cmd` (Windows)

### Hyper-V Generation 2 Windows Server 1803 Standard Image

#### 1803 Generation 2 Prerequisites

For Generation 2 prepare `secondary1803.iso` with folder structure:

* ./extra/files/gen2-1803/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_win2016_1803_g2.cmd` (Windows)

### Hyper-V Generation 2 Windows Server 1809 Standard Image

#### 1809 Generation 2 Prerequisites

For Generation 2 prepare `secondary1809.iso` with folder structure:

* ./extra/files/gen2-1809/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_win2016_1809_g2.cmd` (Windows)

## Templates CentOS 7.x

### Hyper-V Generation 2 CentOS 7.6 Image

Run `hv_centos76_g2.cmd` (Windows)

### Warnings - CentOS

* if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
* folder `./iso` should contain iso image of your Windows 2016 Server Standard (any version will be fine)
* if needed - change `iso_url` variable to a proper iso name
* packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host) and v9 for Windows Server 2019/Windows 10 1809
* credentials for Windows machines: Administrator/password (removed after sysprep)
* credentials for Linux machines: root/password
* for Windows based machines adjust your settings in ./scripts/phase-2.ps1
* for Linux based machines adjust your settings in ./files/gen2-centos/provision.sh and ./files/gen2-centos/puppet.conf

### Vagrant support

Experimental support for vagrant machines `vagrant_hv_centos76_g2.cmd`

### Hyper-V Generation 2 CentOS 7.6 Image with extra docker volume

Run `hv_centos76_g2_docker.cmd` (Windows)

### Warnings - CentOS Docker

* if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
* folder `./iso` should contain iso image of your Windows 2016 Server Standard (any version will be fine)
* if needed - change `iso_url` variable to a proper iso name
* packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host) and v9 for Windows Server 2019/Windows 10 1809
* credentials for Windows machines: Administrator/password (removed after sysprep)
* credentials for Linux machines: root/password
* for Windows based machines adjust your settings in ./scripts/phase-2.ps1
* for Linux based machines adjust your settings in ./files/gen2-centos/provision.sh and ./files/gen2-centos/puppet.conf
* no `docker` repo will be added  and no docker-related packages will be installed

## Known issues

### Infamous UEFI/Secure boot WIndows implementation

During the deployment secure keys are stored in *.vmcx file and are separated from *.vhdx file. To countermeasure it - there is added extra step in a form of (`/usr/local/bin/uefi.sh`) script that will check for existence of CentOS folder in EFI and will add extra entry in UEFI.
In manual setup you can run it as a part of your deploy. In SCVMM deployment I'd recommend using `RunOnce` feature.

### On Windows Server 2019/Windows 10 1809 image boots to fast for packer to react.

[https://github.com/hashicorp/packer/issues/7278#issuecomment-468492880](https://github.com/hashicorp/packer/issues/7278#issuecomment-468492880)

No fixes yes.

### When Hyper-V host has more than one interface Packer sets {{ .HTTPIP }} variable to inproper interface

No resolution so far, template needs to be changed to pass real IP address, or there should be connection between these addresses. Limiting these, end with timeout errors.

### Packer version 1.3.0/1.3.1 have bug with `windows-restart` provisioner

[https://github.com/hashicorp/packer/issues/6733](https://github.com/hashicorp/packer/issues/6733)

### Packer won't run until VirtualSwitch is created as shared

[https://github.com/hashicorp/packer/issues/5023](https://github.com/hashicorp/packer/issues/5023)
Will be fixed in 1.4.x revision

### I have problem how to find a proper WIM  name in Windows ISO to pick proper version.

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

## About

* Marcin Bojko - marcin(at)bojko.com.pl

Work based on [https://github.com/jacqinthebox/packer-templates.git](https://github.com/jacqinthebox/packer-templates.git)
