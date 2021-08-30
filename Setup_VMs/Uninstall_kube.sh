#!/bin/bash
 echo "---------- docker uninstallation ----------"
 
echo "Removing Docker images"
sudo docker rm `docker ps -a -q`
sudo docker rmi `docker images -q`
echo "Images removed successfully"
sudo yum remove -y docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sleep 5
 echo "---------- docker uninstallation successful ----------"
 sleep 1
 
echo "resetting Kubernetes"
  sudo kubeadm reset 
echo "Reset successful"

echo "Removing Kubernetes and its configuration files"
sudo yum remove -y kubeadm kubectl kubelet kubernetes-cni kube*    
sudo yum -y autoremove 
sudo rm -rf ~/.kube
echo "Kubernetes Uninstalled Successfully"
