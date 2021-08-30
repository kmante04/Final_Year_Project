#!/bin/bash

SUB_ADDR=$1
TENANT=$2
REGISTRY_NAME=$3

export REGISTRY_NAME

##Docker Registry Setup
 
_set_hostname()
{
	echo "Changing the hostname of the registry"
	hostnamectl set-hostname $REGISTRY_NAME
	echo "Hostname Changed $REGISTRY_NAME" 
}


_install_and_configure_nfs()
{
	## install nfs-utils
       echo "---------- installation update and package ----------"
               yum install nfs-utils nfs-utils-lib -y
               yum install portmap -y

       echo "---------- NFS-utils has been installed successfully ----------"

       echo "---------- Starting up the services ---------"

       echo "------- enabling up rpcbind --------"      
              sudo systemctl enable rpcbind
       echo "------- rpcbind service has been enabled --------"

       echo "enabling the NFS-server"
              sudo systemctl enable nfs-server
       echo "NFS-server has been enabled"

       echo "Enabling up nfs-lock"
              sudo systemctl enable nfs-lock
       echo "NFS-lock has been enabled successfully"

       echo "Enabling NFS-IDMAP"
              sudo systemctl enable nfs-idmap
       echo "NFS-IDMAP has been enabled successfully"

       echo "starting up rpcbind"
              sudo systemctl start rpcbind
       echo "rpcbind has started successfully"

       echo "starting nfs-server"
              sudo systemctl start nfs-server
       echo "nfs-server has started successfully"

       echo "starting nfs-lock"
              sudo systemctl start nfs-lock
       echo "nfs-lock has started successfully"

       echo "starting nfs-idmap"
              sudo systemctl start nfs-idmap
       echo "nfs-idmap has started successfully"
}


_add_nfs_directory_over_network()
{
## add exports entries
	echo "Adding exports entries"
	cat << EOF >> /etc/exports

/registry                                $SUB_ADDR/24(rw,sync,no_root_squash,no_all_squash)
/certs    		                    $SUB_ADDR/24(rw,sync,no_root_squash,no_all_squash)
/home/k8s_data 	                    $SUB_ADDR/24(rw,sync,no_root_squash,no_all_squash)
EOF

	echo "export entries added"

sleep 2
echo "--------- Restarting NFS-server ----------"
    sudo systemctl restart nfs-server
echo "--------- NFS-server has been restarted ---------"
}


_configure_firewall()
{
##Configuring Firewall

	echo "Configuring firewall and Allowing ports...."

       sudo firewall-cmd --permanent --zone=public --add-service=nfs
       sudo firewall-cmd --permanent --zone=public --add-service=mountd
       sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
	sudo firewall-cmd --reload

	echo "Firewall configured and port allowed successfully"
}


_configure_openssl_env()
{
## Creating Self-Signed SSL Certificate
echo "-------- Installing Openssl ---------"
       sudo yum install openssl -y
echo "-------- OpenSSL Installed Successfully ---------"

echo "--------- Creating the Certs folder ----------- "
sudo mkdir -p /certs
echo "--------- Certs folder created successfully-------"

echo "-------- Creating Self-Signed SSL Certificate ---------"

openssl req -newkey rsa:4096 \
            -x509 \
            -sha256 \
            -days 3650 \
            -nodes \
            -out /certs/registry.crt \
            -keyout /certs/registry.key \
            -subj "/C=GH/ST=Accra/L=Legon/O=Genkey/OU=Support/CN=$REGISTRY_NAME"

echo "--------- Self-Signed SSL Certificate has been created Successfully ----------"

echo "------- creating /etc/docker/certs.d/$REGISTRY_NAME:5000 ---------"
            mkdir -p /etc/docker/certs.d/$REGISTRY_NAME:5000
    echo "------- $REGISTRY_NAME:5000 created ---------"

echo "-------- copying contents in the certs folder to $REGISTRY_NAME:5000-------"
            cp /certs/registry.crt /etc/docker/certs.d/$REGISTRY_NAME:5000
    echo "-------- File transferred successfully --------"
}


_adding_k8s_folders()
{
	##Adding K8s folders and granting permissions

	echo "Creating the K8s Folders with Tenant...."

   mkdir -p /home/k8s_data/mysql_data/$1
    mkdir -p /home/k8s_data/sakai_logs/$1
    mkdir -p /home/k8s_data/tomcat_logs/sakai/$1
    mkdir -p /home/k8s_data/tomcat_logs/turnitin/$1

	echo "Folders have been created Successfully"	
echo "Granting nfs and chmod permission to k8s_data folder"
    sudo chown -R nfsnobody:nfsnobody /home/k8s_data
    sudo chmod -R 777 /home/k8s_data
echo "Permissions Granted"
}


####################################################################
#             Run Installation Prereqs for docker registry         #
####################################################################

./docker_install.sh

_set_hostname

_install_and_configure_nfs

_add_nfs_directory_over_network 

_configure_firewall

_configure_openssl_env

_adding_k8s_folders $TENANT