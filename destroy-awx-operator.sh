#!/bin/bash

set -euo pipefail

if [ -d awx-operator ]; then
  cd awx-operator
  echo -e "\nRemoving awx-operator resources from cluster...\n"
  K8S="microk8s kubectl"
  $K8S delete -f awx-demo.yml --ignore-not-found=true --wait=true --timeout=5m
  $K8S delete -k . --ignore-not-found=true --wait=true --timeout=5m
  
  cd ..
  echo -e "\nRemoving awx-operator directory...\n"
  rm -rf awx-operator
else
  echo -e "\nawx-operator directory does not exist\n"
fi