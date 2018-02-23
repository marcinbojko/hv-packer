#!/bin/bash
# Zeroing
echo "Zeroing phase"
time dd if=/dev/zero|pv -treb|dd of=/plik.zero bs=4096;sync;sync;rm -rfv /plik.zero;sync;sync
echo "Zeroing done"
