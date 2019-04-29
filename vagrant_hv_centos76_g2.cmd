set PACKER_LOG=0
packer validate .\templates\hv_centos76_g2_vagrant.json
packer build  -var "switch_name=Default" .\templates\hv_centos76_g2_vagrant.json 
