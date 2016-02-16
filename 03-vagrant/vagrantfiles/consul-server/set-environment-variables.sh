#!/usr/bin/env bash

while [ $# -ne 0 ]
do
    ARG=$1
    shift
    case $ARG in
    --atlas-environment)
        ATLAS_ENVIRONMENT=$1
        shift
        ;;
    --atlas-token)
        ATLAS_TOKEN=$1
        shift
        ;;
    --consul-servers)
        CONSUL_SERVERS=$1
        shift
        ;;
    --node-name)
        NODE_NAME=$1
        shift
        ;;
    *)
        echo "Error: Unknown Argument - $ARG"
        exit 1
        ;;
    esac
done


cat <<EOF | cat >> /etc/profile.d/consul.sh
ATLAS_ENVIRONMENT=$ATLAS_ENVIRONMENT
ATLAS_TOKEN=$ATLAS_TOKEN
CONSUL_SERVERS=$CONSUL_SERVERS
NODE_NAME=$NODE_NAME
EOF

chmod a+x /etc/profile.d/consul.sh
