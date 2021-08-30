#!/bin/bash

SUB_ADDR=$1
TENANT=$2
REGISTRY_NAME=$3

##Docker Registry Setup
echo "########### Installing Docker Registry Setup #########"
echo "#### ####"
echo "######################################################"

####################################################################
#             Run Installation Prereqs for docker registry         #
####################################################################

./docker_install.sh

./preregistrysetup.sh $SUB_ADDR $TENANT $REGISTRY_NAME

./installDockerRegistry.sh