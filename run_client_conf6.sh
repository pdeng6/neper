#!/bin/bash -x

HOST=192.168.1.4
DURATION=${1:-60}

echo 1024 65535 > /proc/sys/net/ipv4/ip_local_port_range
ulimit -n 999999


/root/os.linux.pnp.tool.bd-redis/redis/set_irq_affinity.bash 0-15 ens6f0d1
taskset -c 16-39,256-279 ./tcp_rr -4 -T 200 -F 30000 -l $DURATION -c -H $HOST
