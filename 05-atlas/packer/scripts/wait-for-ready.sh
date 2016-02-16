#!/bin/bash
set -e

# Wait for cloud-init to do it's thing
timeout 180 /bin/bash -c \
  "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"

# Literally throw away everything cloud-init has done
echo "Cleaning apt-cache..."
sudo rm -rf /var/lib/apt/lists/* &>/dev/null
sudo apt-get --yes clean &>/dev/null

echo "Updating apt-cache..."
sudo apt-get update &>/dev/null
