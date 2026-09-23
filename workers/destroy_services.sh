#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_KEY_NAME="rsa_lab"
cd "$SCRIPT_DIR"

docker compose down --rmi all --volumes

if [[ -f ./${LAB_KEY_NAME} ]]; then
  rm -f ./${LAB_KEY_NAME}*
fi

echo -e "\nAll services, volumes, and images have been destroyed.\n"