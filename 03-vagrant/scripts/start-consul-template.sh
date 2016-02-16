#!/usr/bin/env bash

exec /usr/local/bin/hashicorp/consul-template \
  -log-level debug \
  -config /etc/consul-template/consul-template.cfg \
  >> /var/log/consul-template.log 2>&1
