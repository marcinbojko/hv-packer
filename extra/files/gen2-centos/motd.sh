#!/bin/bash
neofetch
if [ -f ~/.Xauthority ]; then
  xauth merge ~/.Xauthority
fi
export XAUTHORITY=$HOME/.Xauthority

