set PACKER_LOG=0
packer validate -var-file=.\variables\variables_centos77.json .\templates\hv_centos7_g2_docker.json
packer build --force -var-file=.\variables\variables_centos77.json .\templates\hv_centos7_g2_docker.json


