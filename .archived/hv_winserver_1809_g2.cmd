set PACKER_LOG=0
packer version
packer validate -var-file=.\variables\variables_winserver_1809.json .\templates\hv_winserver_g2.json
packer build --force -var-file=.\variables\variables_winserver_1809.json .\templates\hv_winserver_g2.json

