#!/usr/bin/env bash
# prepare (comment/uncomment lines according to our needs)

config="/etc/neofetch/config.conf"
config_dir="/etc/neofetch"

if [ ! -d $config_dir ];then
 echo "No $config_dir exists - creating one"
 mkdir -v $config_dir
fi

if [ ! -e $config ];then
  if [ -e /root/.config/neofetch/config.conf ];then
  echo "Copying config from root to /etc/neofetch"
  cp -pv /root/.config/neofetch/config.conf $config
  fi
fi

if [ -e $config ]; then
  echo "Starting Neofetch configuration"
  # comment
  sed -i -e 's/^[[:blank:]]*info "Packages" packages/#info "Packages" packages/g' $config
  sed -i -e 's/^[[:blank:]]*info "Resolution" resolution/#info "Resolution" resolution/g' $config
  sed -i -e 's/^[[:blank:]]*info "DE" de/#info "DE" de/g' $config
  sed -i -e 's/^[[:blank:]]*info "WM" wm/#info "WM" wm/g' $config
  sed -i -e 's/^[[:blank:]]*info "WM Theme" wm_theme/#info "WM Theme" wm_theme/g' $config
  sed -i -e 's/^[[:blank:]]*info "Theme" theme/#info "Theme" theme/g' $config
  sed -i -e 's/^[[:blank:]]*info "Icons" icons/#info "Icons" icons/g' $config
  sed -i -e 's/^[[:blank:]]*info "Terminal" term/#info "Terminal" term/g' $config
  sed -i -e 's/^[[:blank:]]*info "Terminal Font" term_font/#info "Terminal Font" term_font/g' $config
  sed -i -e 's/^[[:blank:]]*info cols/#info cols/g' $config
  # uncomment
  sed -i -e 's/^[[:blank:]]*# info "Disk" disk/info "Disk" disk/g' $config
  sed -i -e 's/^[[:blank:]]*# info "Local IP" local_ip/info "Local IP" local_ip/g' $config
  # disable color block - workaround for HV console
  sed -i -e 's/color_blocks="on"/color_blocks="off"/g' $config
  echo "Finished Neofetch configuration"
else
 echo "File $config doesn't exist - couldn't configure neofetch"
fi
