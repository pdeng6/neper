#!/bin/bash -x

echo 1024 65535 > /proc/sys/net/ipv4/ip_local_port_range
ulimit -n 999999
THREAD=60

/root/os.linux.pnp.tool.bd-redis/redis/set_irq_affinity.bash 0-15 ens6f0d1

CMD="./tcp_rr -4 -T $THREAD -F 30000 -l 3600 -H 192.168.1.4"

taskset -c 16-39,256-279 $CMD
