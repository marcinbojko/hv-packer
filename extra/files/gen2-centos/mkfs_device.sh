#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'No parameters given, I need device and mountpoint'
    exit 1
else
    # main loop
    if [ -b $1 ];then
    echo "$1 exists"
    device=$1
    if [ -z "$(/usr/sbin/sfdisk -d $device 2>&1)" ]; then
      echo "$device doesn't have partitions"
      /usr/sbin/parted --script $device \
      mklabel gpt \
      mkpart primary 2048s 100% \
      print devices
      # end of parted script
      part=$device'1'
      sleep 3
      echo $part
      /usr/sbin/partprobe -s $device
      sleep 2
      /usr/sbin/mkfs.ext4 $part
      echo "done paritioning"
    fi
    else
    echo "$1 doesn't exists"
    fi
fi
