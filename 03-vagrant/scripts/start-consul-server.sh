#!/usr/bin/env bash

BIND=$(ifconfig | \
grep 'inet' | \
grep -v '127.0.0.1' | \
cut -d: -f2 | \
awk '{ print $2}' | \
tr -d '\n')

exec /usr/local/bin/hashicorp/consul agent \
  -server \
  -bootstrap-expect=$CONSUL_SERVERS \
  -ui \
  -data-dir=/mnt/consul \
  -config-dir=/etc/consul.d \
  -atlas-join \
  -atlas-token=$ATLAS_TOKEN \
  -atlas=$ATLAS_ENVIRONMENT \
  -node=$NODE_NAME \
  -bind=$BIND \
  >> /var/log/consul-server.log 2>&1
