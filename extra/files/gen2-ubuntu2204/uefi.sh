#!/usr/bin/env bash
# try to deal with broken centos/ubuntu UEFI in Hyper-V

# Let's find out which bootnumber we have currently in UEFI with Ubuntu label
bootnum=$(efibootmgr -v|grep -i ubuntu|awk '{print $1}'|cut -c5-8)

if [ -d "/boot/efi/EFI/ubuntu" ]; then
    echo "Ubuntu exists"
    # now centos exists
    if [ -z "$bootnum" ]; then
        echo "Current Ubuntu boot number equals: $bootnum"
        efibootmgr -b "$bootnum" -B
        efibootmgr --create --label Ubuntu --disk /dev/sda1 --loader "\EFI\ubuntu\shim.efi"
        sudo grub2-mkconfig -o /boot/efi/EFI/BOOT/grub.cfg
        efibootmgr -v
    fi
fi
