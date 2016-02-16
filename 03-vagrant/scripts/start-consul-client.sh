#!/usr/bin/env bash

exec /usr/local/bin/hashicorp/consul agent \
  -data-dir=/mnt/consul \
  -config-dir=/etc/consul.d \
  -atlas-join \
  -atlas-token=$ATLAS_TOKEN \
  -atlas=$ATLAS_ENVIRONMENT \
  -node=$NODE_NAME \
  >> /var/log/consul-client.log 2>&1
