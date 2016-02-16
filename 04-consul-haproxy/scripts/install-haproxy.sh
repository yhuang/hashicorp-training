#!/bin/bash
set -e

# Literally throw away everything cloud-init has done
echo "Installing haproxy..."
sudo add-apt-repository ppa:vbernat/haproxy-1.5 --yes
sudo apt-get --yes update &>/dev/null
sudo apt-get install haproxy
