#!/bin/bash
# Zeroing
echo "Zeroing phase"
  time dd if=/dev/zero|pv -treb|dd of=/file.zero bs=4096;sync;sync;rm -rfv /file.zero;sync;sync
  rm -rfv /file.zero||true
echo "Zeroing done"
