# Set of various shared scripts and files for packer templates

## 2019-03-04

* disabled `Install-WindowsFeature NET-Framework-Core,NET-Framework-Features,PowerShell-V2 -IncludeManagementTools` in phase-1.ps1 script.

## 2018-12-29

* [Windows] reworked `phase-1.ps1` script to recognise Windows version to adjust proper config for it
* [Windows] reworked `phase-1.ps1` removed Spectre/Meltdown migitation entries

## 2018-12-03

* [CentOS] remove port 8140 from firewalld configuration
* [CentOS] change zabbix repository to version 4.x (won't work with Zabbix server below 4.x)
* [CentOS] added log cleaning/rotating after build
* [CentOS] upgraded SCVMM agent to version 1.0.3.1022. For older SCVMM older agent (1.0.2) is also available
* [Windows] lock `puppet-agent` on version 5.5.8
* [Windows] set `Disable-WindowsErrorReporting` for Windows based machines

## 2018-11-08

* [Windows] puppet version set to 5.5.7
* [Windows] disable Windows Error Reporting.

## 2018-05-31

### CentOS

* added telnet ncdu screen to `provision.sh`
