#!/bin/bash

set -euo pipefail

if [ -d awx-operator ]; then
  rm -rf awx-operator
fi
git clone --depth 1 --branch 2.19.1 https://github.com/ansible/awx-operator.git
cp ./awx-demo.yml ./kustomization.yaml awx-operator/
cd awx-operator

K8S="microk8s kubectl"

# Step 1: apply only the operator manifests so the CRD gets registered first
$K8S apply -k .
$K8S config set-context --current --namespace=awx

echo -e "\nWaiting for AWX CRD to be established..."
$K8S wait --for=condition=Established "crd/awxs.awx.ansible.com" --timeout=120s

# Step 2: now apply the AWX CR
$K8S apply -f awx-demo.yml

echo -e "\nWaiting for awx-demo-admin-password secret to be created..."
for i in $(seq 1 60); do
  $K8S get secret awx-demo-admin-password &>/dev/null && break
  sleep 5
done
$K8S get secret awx-demo-admin-password &>/dev/null || { echo "ERROR: awx-demo-admin-password secret not created after 5m" >&2; exit 1; }

echo -e "\nWaiting for awx-demo-service to be created..."
for i in $(seq 1 60); do
  $K8S get svc awx-demo-service &>/dev/null && break
  sleep 5
done
$K8S get svc awx-demo-service &>/dev/null || { echo "ERROR: awx-demo-service not created after 5m" >&2; exit 1; }

echo -e "\nAccess AWX Web UI: microk8s kubectl port-forward svc/awx-demo-service 5000:80\n"

ADMIN_PASSWORD=$($K8S get secret awx-demo-admin-password \
  -o jsonpath="{.data.password}" | base64 --decode)
echo -e "\nAdmin password: $ADMIN_PASSWORD\n"
