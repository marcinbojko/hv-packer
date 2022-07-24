#!/usr/bin/env bash
mkdir /tmp/parallels
mount /dev/sr1 /tmp/parallels
cd /tmp/parallels||exit
./install --install-unattended-with-deps
sleep 3
cd /
umount /tmp/parallels
sleep 3
exit 0
