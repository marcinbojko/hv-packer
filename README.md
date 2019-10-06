# Set of packer scripts to create Hyper-V VMs

## Requirements

* packer <=`1.4.4`. Do not use packer below 1.4.4. For previous packer versions use previous releases from this repository
* Microsoft Hyper-V Server 2016/2019 or Microsoft Windows Server 2016/2019 (not 2012/R2)
* [OPTIONAL] Vagrant >= `2.2.5` - for `vagrant` version of scripts

## Usage

### Install packer from Chocolatey

```cmd
choco install packer --version=1.4.4
```

### Add firewal exclusions for TCP ports 8000-9000 (default range)

```powershell
Remove-NetFirewallRule -DisplayName "Packer_http_server" -Verbose
New-NetFirewallRule -DisplayName "Packer_http_server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000-9000

```

### To adjust to your Hyper-V, please check variables below

* proper VLAN (possible passing as variable `-var 'vlan_id=0'` )
* proper Hyper-V Virtual Switch name (access to Internet will be required) (possible passing as variable `-var 'switch_name=vSwitch'` )
* proper URL for ISO images in packer's template (possible passing as variable `-var 'iso_url=file.iso'` )
* proper checksum type (possible passing as variable `-var 'iso_checksum_type=sha256'` )
* proper checksum  (possible passing as variable `-var 'iso_checksum=aaaabbbbbbbcccccccddddd'` )

## Scripts

### Windows Machines

* all available updates will be applied (3 passes)
* latest version of chocolatey
* packages from a list below:

  |Package|Version|
  |-------|-------|
  |puppet-agent|5.5.16|
  |conemu|latest|
  |dotnetfx|latest|
  |sysinternals|latest|
* latest Nuget poweshell module
* puppet agent settings will be customized (`server=foreman.spcph.local`). Please adjust it (`/extra/scripts/phase-3.ps1`) to suit your needs. Puppet won't be running after generalize phase

### Linux Machines

* Repositories:
  * EPEL 7
  * Zabbix 4.2
  * Puppet 5.x [can be switch off by -p false]
  * Webmin/Usermin (can be switched off by setting )
  * Neofetch
* latest System Center Virtual Machine Agent available (with versioning, so you always can go back)

### Info

* adjust `/files/provision.sh` to modify package's versions/servers.
* change "provision_script_options" variable to:
  * -p (true/false) - switch Install Puppet on/off
  * -w (true/false) - switch Install Webmin on/off
  * -h (true/false) - switch Install Hyper-V integration services on/off
  * -u (true/false) - switch yum update all on/off (usable when creating previous than `latest` version of OS)
Example:

```json
"provision_script_options": "-p false -u true -w true -h false"
```

* `prepare_neofetch.sh` -  default banner during after the login - change required fields you'd like to see in `provision.sh`

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

Run `hv_win2019_dc_g2.cmd`

### Hyper-V Generation 2 Windows Server 1809 Standard Image

If you need changes For - prepare `secondary1809.iso` with folder structure:

* ./extra/files/gen2-1809/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_winserver_1809_g2.cmd`

### Hyper-V Generation 2 Windows Server 1903 Standard Image

If you need changes For - prepare `secondary1903.iso` with folder structure:

* ./extra/files/gen2-1903/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_winserver_1903_g2.cmd`

## Templates CentOS 7.x

### Hyper-V Generation 2 CentOS 7.7 Image

Run `hv_centos77_g2.cmd`

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

Experimental support for vagrant machines `hv_centos77_g2_vagrant.cmd`

### Hyper-V Generation 2 CentOS 7.7 Image with extra docker volume

Run `hv_centos77_g2_docker.cmd`

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

## About

* Marcin Bojko - marcin(at)bojko.com.pl

Work based on [https://github.com/jacqinthebox/packer-templates.git](https://github.com/jacqinthebox/packer-templates.git)
