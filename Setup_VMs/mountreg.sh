#!/bin/bash

REG_IP_ADDR=$1

##mount registry folders

_create_certs_and_registry_folder()
{
    echo "------- Creating the certs folder on VM --------"
            mkdir -p /certs 
    echo "------- certs folder created successfully --------"
}

_mount_certs_and_registry_folder()
{

    echo "--------- mounting the certs folder ------------"
            mount $1:/certs /certs
    echo "--------- certs folder mounted successfully ----------"
}
####################################################################
#             Run mountreg for Kubernetes nodes         #
####################################################################

_create_certs_and_registry_folder 

_mount_certs_and_registry_folder $REG_IP_ADDR

 
