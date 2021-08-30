#!/bin/bash

#. ./setk8senv
# pre-requisites for k8s (workernode1)
## set hostname
NODE_NAME=$1
REGISTRY_NAME=$2

./runPrereqs.sh $NODE_NAME $REGISTRY_NAME
