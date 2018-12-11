# Set of various shared scripts and files for packer templates

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
