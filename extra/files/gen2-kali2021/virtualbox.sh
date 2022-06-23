#!/usr/bin/env bash

echo "Executing scripts/virtualbox.sh"

if [ -f /tmp/VBoxGuestAdditions.iso ]; then
    mount -o loop /tmp/VBoxGuestAdditions.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    rc=$?
    umount /mnt
    rm -rf /tmp/VBoxGuestAdditions.iso

    if [ $rc -ne 0 ]; then
        cat /var/log/VBoxGuestAdditions.log
        exit $rc
    else
        echo "Virtualbox guest addons have been installed successfully"
        exit 0
    fi
else
    echo "No VBoxGuestAdditions.iso could be found"
    exit 0
fi
exit 0
