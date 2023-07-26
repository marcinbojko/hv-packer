#!/bin/bash
# try to deal with broken centos UEFI in Hyper-V

# Let's find out which bootnumber we have currently in UEFI with CentOS label
bootnum=$(efibootmgr -v|grep -i oracle|awk '{print $1}'|cut -c5-8)

if [ -d "/boot/efi/EFI/oracle" ]; then
    echo "Oracle exists"
    # cp -av /boot/efi/EFI/centos/. /boot/efi/EFI/BOOT/
    # now centos exists
    if [ -z "$bootnum" ]; then
        echo "Current Oracle boot number equals: $bootnum"
        efibootmgr -b "$bootnum" -B
        efibootmgr --create --label OracleLinux --disk /dev/sda1 --loader "\EFI\oracle\shim.efi"
        sudo grub2-mkconfig -o /boot/efi/EFI/BOOT/grub.cfg
        efibootmgr -v
    fi
fi
