#!/bin/bash -x

CONF=conf1
CONF=conf4
CONF=conf6
CONF=conf10
RUN_SERVER_SCRIPT=./run_server_$CONF.sh
RUN_CLIENT_SCRIPT="./run_client_$CONF.sh 1>client.$CONF.log 2>&1"

DEVICE=ens6f0d1

# launch server 
$RUN_SERVER_SCRIPT &
server_pid=$!
sleep 5

# launch client
ssh -o ServerAliveInterval=30 root@192.168.1.1 "cd /root/neper && $RUN_CLIENT_SCRIPT"
