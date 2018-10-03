#!/bin/bash
echo "validating ./templates/hv_centos75_g2.json"
packer validate ./templates/hv_centos75_g2.json
echo "validating ./templates/hv_win2016_g1.json"
packer validate ./templates/hv_win2016_g1.json
echo "validating ./templates/hv_win2016_g2.json"
packer validate ./templates/hv_win2016_g2.json
echo "validating ./templates/hv_win2016_1709_g2.json"
packer validate ./templates/hv_win2016_1709_g2.json
echo "validating ./templates/hv_win2016_1803_g2.json"
packer validate ./templates/hv_win2016_1803_g2.json
