#!/usr/bin/env bash

# Consul Client Setup
mv /tmp/haproxy-health-check.json /etc/consul.d/haproxy-health-check.json

mv /tmp/start-consul-client.sh /usr/local/bin/start-consul-client.sh
chmod a+x /usr/local/bin/start-consul-client.sh

mv /tmp/consul-client.service /etc/systemd/system/consul.service

# Consul Template Setup
mkdir -p /etc/consul-template
mv /tmp/consul-template.cfg /etc/consul-template/consul-template.cfg
mv /tmp/haproxy.cfg.ctmpl /etc/consul-template/haproxy.cfg.ctmpl

mv /tmp/start-consul-template.sh /usr/local/bin/start-consul-template.sh
chmod a+x /usr/local/bin/start-consul-template.sh

mv /tmp/consul-template.service /etc/systemd/system/consul-template.service
