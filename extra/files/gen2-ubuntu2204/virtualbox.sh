#!/usr/bin/env bash

echo "Executing scripts/virtualbox.sh"

if [ -f /tmp/VBoxGuestAdditions.iso ]; then
    mount -o loop /tmp/VBoxGuestAdditions.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    rc=$?
    umount /mnt
    rm -rf /tmp/VBoxGuestAdditions.iso

    if [ $rc -ne 0 ]; then
        if [ -e /var/log/VBoxGuestAdditions.log ]; then
            cat /var/log/VBoxGuestAdditions.log
        fi
        exit $rc
    else
        echo "Virtualbox guest addons have been installed successfully"
        exit 0
    fi
else
    echo "No VBoxGuestAdditions.iso could be found"
    exit 1
fi
exit 0
