#!/bin/bash

# pre-requisites for k8s (master)
## set hostname

#. ./setk8senv

#_add_a_user()
###{
 # USER=$1
#  PASSWORD=$2
#  shift; shift;
  # Having shifted twice, the rest is now comments ...
#  COMMENTS=$@
#  echo "Adding user $USER ..."
#  echo useradd -c "$COMMENTS" $USER
#  echo passwd $USER $PASSWORD
#  echo "Added user $USER ($COMMENTS) with pass $PASSWORD"
#}
NODE_NAME=$1
REGISTRY_NAME=$2

echo "---------- Kubernetes installation start. ----------" 
sleep 3

_configure_k8s()
{
	## enable bash completion for both
	echo "enable bash completion for both kubeadm and kubectl"
	kubeadm completion bash > /etc/bash_completion.d/kubeadm
	kubectl completion bash > /etc/bash_completion.d/kubectl
	echo "Bash completion has been enabled successfully"

	## activate the completion
	. /etc/profile
	
	# initialize cluster
	echo "Initializing Kubernetes cluster"
	kubeadm init
	echo "Kubernetes cluster has been initialized successfully"
	# copy the credentials to your user
#	echo "Copying the credentials as a regular user"

	#_add_a_user k8sAdsmin k8sAdsmin k8s cluster administrator

	##su - k8sAdsmin
	#echo "Regular user k8sAdsmin created"

	 mkdir -p $HOME/.kube
	 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	 sudo chown $(id -u):$(id -g) $HOME/.kube/config

	echo "Credentials applied successfully"

	# install networking
	echo "installing Weavenet pod network"
	kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
	echo "Pod network install complete"

	#Generating token 
	#echo "Generating token for Kubernetes Cluster"
	#kubeadm token create --print-join-command
	#token=$(kubeadm token create --print-join-command)
	#echo " Token Generated"

	#echo "Writing token string to file"
	
	#echo token > NFS_SHARE/token_$(date "+%Y.%m.%d-%H.%M.%S")
	
#	cat << EOF > /home/token.sh
#	#!/bin/bash
#	echo $token
#EOF

	#echo "token has been written successfully"
	echo "Congratulations, the kubernetes master installation is complete. Please check the following command and run the kubernetes-slave.sh file." 
echo


	
	exit
}




 

####################################################################
# 			Installation steps for k8s							   #
####################################################################

#_set_hostname
#
#_update_os
#
#_add_nodes_to_hosts_file
#
#_install_and_configure_docker
#
#_configure_k8s_env
#
#_install_k8s

./runPrereqs.sh $NODE_NAME $REGISTRY_NAME

_configure_k8s




