#!/bin/bash -x

ulimit -n 999999

IRQ_CPUSET=0-62
NIC_DEV=ens41f0np0
HOST=192.168.100.1

NEPER_CPUSET=63-239

# ethtool -l $NIC_DEV to get maximum preset channels
# if VFS=1, SRVS_PAIRS_PER_VFS should be the maximum
# SRVS_PAIRS_PER_VFS = (maximum preset channels) / VFS#
SRVS_PAIRS_PER_VFS=63

ethtool -L $NIC_DEV combined $SRVS_PAIRS_PER_VFS

# dependency: set_irq_affinity.bash
./set_irq_affinity.bash $IRQ_CPUSET $NIC_DEV

taskset -c $NEPER_CPUSET ./tcp_rr -4 -T 200 -F 30000 -l 3600 -H $HOST

