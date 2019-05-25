set PACKER_LOG=0
packer validate .\templates\hv_centos76_g2_docker.json
packer build --force .\templates\hv_centos76_g2_docker.json
