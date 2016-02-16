#!/bin/bash
set -e

echo "Installing dependencies..."
sudo apt-get update -y &>/dev/null
sudo apt-get install -y unzip

echo "Fetching Consul Template..."
cd /tmp
curl -s -L -o consul-template.zip https://releases.hashicorp.com/consul-template/0.12.2/consul-template_0.12.2_linux_amd64.zip

echo "Installing Consul Template..."
unzip /tmp/consul-template.zip
sudo chmod +x consul-template
sudo mv consul-template /usr/local/bin/consul-template

echo "Installing Upstart service..."
sudo mv /tmp/consul-template.conf /etc/init/consul-template.conf

echo "Setting up templates directory..."
sudo mkdir -p /etc/consul-template

for FILENAME in $(find /tmp -iname '*.ctmpl' -type f); do
  FILENAME=$(basename $FILENAME)
  sudo mv "/tmp/${FILENAME}" "/etc/consul-template/${FILENAME}"
done

echo "Starting Consul Template..."
sudo start consul-template
