#!/bin/bash
set -e

echo "Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y unzip

echo "Fetching Consul..."
cd /tmp
curl -L -o consul.zip https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -p /etc/consul.d
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/service

echo "Installing Upstart service..."
sudo mv /tmp/upstart.conf /etc/init/consul.conf
