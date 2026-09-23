#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_KEY_NAME="rsa_lab"
cd "$SCRIPT_DIR"

echo -e "\nGenerating SSH keys for lab\n"
if [[ -f ./${LAB_KEY_NAME} ]]; then
  rm -f ./${LAB_KEY_NAME}*
fi
ssh-keygen -t rsa -b 4096 -C "recursivedeveloper" -f "./${LAB_KEY_NAME}" -N ""

echo -e "\nDeploying services\n"
docker compose --progress auto up -d

echo -e "\nServices deployed successfully.\n"
docker compose ps