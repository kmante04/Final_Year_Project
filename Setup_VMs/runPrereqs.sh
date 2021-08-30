#!/bin/bash

NODE_NAME=$1
REGISTRY_NAME=$2

source ./setk8senv.sh

_set_hostname()
{
	echo "Changing the hostname of the machine"
	hostnamectl set-hostname $1
	echo "Hostname Changed $1" 
}



_add_nodes_to_hosts_file()
{
## add hosts entries
	echo "Adding hosts entries"
	cat << EOF >> /etc/hosts

# my k8s
$MASTER_NODE_IP  masternode
$WORKER_NODE_1   workernode1
$WORKER_NODE_2   workernode2
$WORKER_NODE_3   workernode3
$WORKER_NODE_4	 workernode4
$REGISTRY_NODE  $REGISTRY_NAME
EOF

	echo "Host entries added"
}
 
_update_os()
{
	echo "---------- installation update and package ----------"

						sudo yum -y update

# Disable swap
echo " ----------------- Disable swap ----------"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo " ----------------- swapoff done ----------"
}

 
_install_and_configure_docker()
{		
		echo "Setting up and configuring"
		echo "------- creating /etc/docker/certs.d/$REGISTRY_NAME:5000 ---------"
            mkdir -p /etc/docker/certs.d/$REGISTRY_NAME:5000
    	echo "------- $REGISTRY_NAME:5000 created ---------"
		
   		echo "-------- copying contents in the certs folder to $REGISTRY_NAME:5000-------"
            cp /certs/registry.crt /etc/docker/certs.d/$REGISTRY_NAME:5000
    	echo "-------- File transferred successfully --------"

	echo "---------- docker installation complete. ----------" 
}



_configure_k8s_env()
{
	##Configuring Firewall

	echo "Configuring firewall and Allowing ports...."
	sudo firewall-cmd --permanent --add-port=53/tcp
	sudo firewall-cmd --permanent --add-port=53/udp
	sudo firewall-cmd --permanent --add-port=6443/tcp
	sudo firewall-cmd --permanent --add-port=2379-2380/tcp
	sudo firewall-cmd --permanent --add-port=10250/tcp
	sudo firewall-cmd --permanent --add-port=10251/tcp
	sudo firewall-cmd --permanent --add-port=10252/tcp
	sudo firewall-cmd --permanent --add-port=10255/tcp
	sudo firewall-cmd --permanent --add-port=9153/tcp
	sudo firewall-cmd --permanent --add-port=6783/tcp
	sudo firewall-cmd --permanent --add-port=6783/udp
	sudo firewall-cmd --permanent --add-port=6784/udp
	sudo firewall-cmd --reload

	echo "Firewall configured and port allowed successfully"
	
	## enable bridge-nf-call-iptables for ipv4 and ipv6
	echo "Enabling bridge-nf-call-iptables for ipv4 and ipv6"

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.conf.all.forwarding=1
net.bridge.bridge-nf-call-arptables=1
EOF

	sysctl --system

	echo "bridge-nf-call-iptables for ipv4 and ipv6 enabled successfully"

	#Using modfilter
	echo "Issuing the modprobe command"
	
	modprobe br_netfilter
	echo "modprobe command issued successfully"

	# disable SELinux
	echo "Disabling SELinux"
	setenforce 0
	sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
	echo "SELinux disabled"
}


_install_k8s()
{
	echo "---------- Kubernetes installation start. ----------" 

	echo "####################################################"
	# install kubeadm
	## add repo
	echo "Adding Repo for installing Kubeadm"

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
	echo "Repo Added"

	## install kubelet, kubeadm and kubectl
	echo "Installing kubelet, kubeadm and kubectl"

	sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

	echo "kubelet, kubeadm and kubectl installed succesfully"
 
	## enable and start kubelet
	echo "Enabling kubelet ...."
	systemctl enable kubelet
	echo "kubelet has been enabled successfully, Therefore being started  "
	systemctl start kubelet
	echo "kubelet has started successfully"

	echo "##############################################################"
	echo "---------- kubernetes installation complete confirm to nodes ----------" 

	echo "Congratulations, the kubernetes preRequisite installation is complete." 
	echo
}





####################################################################
# 			Run Installation Prereqs for k8s					   #
####################################################################

_set_hostname $NODE_NAME

_add_nodes_to_hosts_file

_update_os

./docker_install.sh

_install_and_configure_docker

_configure_k8s_env

_install_k8s
