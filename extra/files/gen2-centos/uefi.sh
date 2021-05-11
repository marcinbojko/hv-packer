#!/bin/bash
# try to deal with broken centos UEFI in Hyper-V

# Let's find out which bootnumber we have currently in UEFI with CentOS label
bootnum=$(efibootmgr -v|grep -i centos|awk '{print $1}'|cut -c5-8)

if [ -d "/boot/efi/EFI/centos" ]; then
    echo "Centos exists"
    # now centos exists
    if [ -z "$bootnum" ]; then
        echo "Current CentOS boot number equals: $bootnum"
        efibootmgr -b "$bootnum" -B
        efibootmgr --create --label CentOS --disk /dev/sda1 --loader "\EFI\centos\shim.efi"
        sudo grub2-mkconfig -o /boot/efi/EFI/BOOT/grub.cfg
        efibootmgr -v
    fi
fi

