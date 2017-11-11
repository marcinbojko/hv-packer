#!/bin/bash
packer validate ./templates/hv_centos74_g2.json
packer build ./templates/hv_centos74_g2.json
