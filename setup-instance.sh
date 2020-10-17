#!/bin/bash
RED='\033[0;31m'
GRN='\033[0;32m'     
LGRN='\033[1;32m'
NC='\033[0m'

echoinfo() { echo -e "${GRN}${1}${NC}"; }
echoimp() { echo -e "${LGRN}${1}${NC}"; }
echoissue() { echo -e "${RED}${1}${NC}"; }

if test -f "/data/test"; then
    echoinfo "Looks like /data is already mounted, skipping fstab updates..."
else
    echoissue "Need to mount efs storage volume at /data..."
    # start by adding the efs storage volume to fstab and mounting to /data
    # 1) create mount point 2) backup fstab 3) add nfs vol to fstab 4) reload fstab
    sudo mkdir -p /data
    sudo cp /etc/fstab /etc/fstab.bak
    echo "172.31.32.82:/    /data    nfs    nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport    0 0" | sudo tee -a /etc/fstab
    sudo mount -av
fi

if [ -d "/home/ubuntu/v2" ]; then
    echoinfo "Looks like the class repo has already been cloned and image build...skipping..."
else
    # clone class repo and build docker image
    echoissue "Need to clone class repo and build docker image..."
    sudo chmod go+rw /data
    cd ~
    git clone https://github.com/MIDS-scaling-up/v2.git
    cd v2/week09/hw/docker
    docker build . --tag hw9
fi

if cat /etc/systemd/system/docker.service.d/override.conf | grep -i nvidia  > /dev/null; then
    echoinfo "Looks like the nvidia docker runtime has already been setup...skipping..."
else
    echoissue "Need to update docker config to include nvidia runtime..."
    # update docker to make the nvidia runtime available
    sudo mkdir -p /etc/systemd/system/docker.service.d
    sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
fi

if docker ps | grep openseq2seq > /dev/null; then
    echoinfo "Looks like the openseq2seq container is already running...skipping..."
else
    echoissue "Need to start openseq2seq docker container..."
    # start-up the container
    docker run --runtime=nvidia -d --name openseq2seq --net=host -e SSH_PORT=4444 -v /data:/data -p 6006:6006 hw9
fi
