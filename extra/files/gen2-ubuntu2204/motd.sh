#!/usr/bin/env bash
neofetch --config /etc/neofetch/config.conf
if [ -f ~/.Xauthority ]; then
  xauth merge ~/.Xauthority
fi
export XAUTHORITY=$HOME/.Xauthority

