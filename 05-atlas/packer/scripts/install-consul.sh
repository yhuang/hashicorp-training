#!/bin/bash
set -e

echo "Installing dependencies..."
sudo apt-get update -y &>/dev/null
sudo apt-get install -y unzip

echo "Fetching Consul..."
cd /tmp
curl -s -L -o consul.zip https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -p /etc/consul.d
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/service

for FILENAME in $(find /tmp -iname '*.json' -type f); do
  FILENAME=$(basename $FILENAME)
  sudo mv "/tmp/${FILENAME}" "/etc/consul.d/${FILENAME}"
done

echo "Installing Upstart service..."
sudo mv /tmp/consul.conf /etc/init/consul.conf

echo "Starting Consul..."
sudo start consul
