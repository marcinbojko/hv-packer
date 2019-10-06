set PACKER_LOG=0
packer version
packer validate -var-file=.\variables\variables_centos76.json .\templates\hv_centos7_g2.json
packer build --force -var-file=.\variables\variables_centos76.json .\templates\hv_centos7_g2.json
