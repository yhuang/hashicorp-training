#!/usr/bin/env bash

mv /tmp/start-consul-server.sh /usr/local/bin/start-consul-server.sh
chmod a+x /usr/local/bin/start-consul-server.sh

mv /tmp/consul-server.service /etc/systemd/system/consul.service
