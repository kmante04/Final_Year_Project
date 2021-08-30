#!/bin/bash

#specifying environment variables
#export DATA_VOL="/home"

_install_required_packages()
{
    # Install required packages
    echo "Installing Required Packages"
    sudo yum install -y yum-utils
    echo "Packages Installed"
}

_install_and_configure_docker()
{
	## install docker

	if [[ $(which docker) && $(docker --version) ]]; then
		echo "docker already installed"

	  else
		echo "Installing docker .."
		sudo yum install -y yum-utils device-mapper-persistent-data lvm2
		echo "adding docker repo .."
		sudo yum-config-manager  --add-repo https://download.docker.com/linux/centos/docker-ce.repo
		echo "docker repo added"
		
		sudo yum update -y && sudo yum install -y \
		containerd.io-1.2.13 \
		docker-ce-19.03.11 \
		docker-ce-cli-19.03.11
		echo "Docker has successfully been installed"
        
		## enable docker and start it
		
		echo "Setting up the Docker daemon"
		
		sudo mkdir /etc/docker
		cat <<EOF | sudo tee /etc/docker/daemon.json
		{
			"exec-opts": ["native.cgroupdriver=systemd"],
			"log-driver": "json-file",
			"log-opts": {
			"max-size": "100m"
		},
			"storage-driver": "overlay2",
			"storage-opts": [
			"overlay2.override_kernel_check=true"
			]
		}
EOF
		echo "Docker daemon Set-up successfuly"

        echo "Creating /etc/systemd/system/docker.service.d"
		sudo mkdir -p /etc/systemd/system/docker.service.d
		echo "docker.service.d directory created"
		
		echo "Enabling Docker ...."
		sleep 1
		systemctl enable docker 
		echo "Docker has been enabled successfully, Therefore being started "
		
		echo "Restarting docker"
		sleep 1
		sudo systemctl daemon-reload
		sudo systemctl restart docker
		echo "Docker Installation succesfully done" 
		
	fi
}

    echo "Installation Complete"


####################################################################
# 			Installation steps for docker						    #
####################################################################

_install_required_packages

_install_and_configure_docker


