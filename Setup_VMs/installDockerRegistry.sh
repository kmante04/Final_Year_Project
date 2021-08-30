#! /bin/sh

#INstallation of local Docker Registry 
export DATA_VOL=/home

echo "Pull docker registry image"

docker pull registry 

echo "Done pulling registry"

echo "Install service scripts for docker registry"

cp docker_registry docker_registry.service /etc/systemd/system/

echo "Enable registry"
systemctl enable docker_registry.service
echo "Setting up Folder to house local registry Images"

cd $DATA_VOL
mkdir dockerRegistry

echo "Start docker registry"
systemctl start docker_registry.service

echo "Done Installing and Configuring Docker registry "

