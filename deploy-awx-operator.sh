#!/bin/bash

set -euo pipefail

if [ -d awx-operator ]; then
  rm -rf awx-operator
fi
git clone --depth 1 --branch 2.19.1 https://github.com/ansible/awx-operator.git
cp ./awx-demo.yml ./kustomization.yaml awx-operator/
cd awx-operator

K8S="microk8s kubectl"
$K8S apply -k .

$K8S config set-context --current --namespace=awx

echo -e "\nWaiting for awx-demo-admin-password secret to be created..."
until $K8S get secret awx-demo-admin-password &>/dev/null; do
  sleep 5
done

echo -e "\nWaiting for awx-demo-service to be created..."
until $K8S get svc awx-demo-service &>/dev/null; do
  sleep 5
done

echo -e "\nWaiting for awx-demo-web deployment to be created..."
until $K8S get deployment awx-demo-web &>/dev/null; do
  sleep 5
done

echo -e "\nWaiting for awx-demo-web deployment to be ready..."
$K8S rollout status deployment/awx-demo-web --timeout=5m

echo -e "\nAccess AWX Web UI: microk8s kubectl port-forward svc/awx-demo-service 5000:80\n"

ADMIN_PASSWORD=$($K8S get secret awx-demo-admin-password \
  -o jsonpath="{.data.password}" | base64 --decode)
echo -e "\nAdmin password: $ADMIN_PASSWORD\n"
