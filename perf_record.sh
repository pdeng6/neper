#!/bin/bash -x

ODATA=perf.icx.tcprr.server
VMLINUX=/home/pnp/pdeng6/my_kernels/kernel-6.12.0+-106/vmlinux

perf record -o $ODATA.data -m 8M -ag -e cycles:P,instructions:P --call-graph=dwarf,512 -F 199 --sample-cpu sleep 10
perf report -i $ODATA.data > $ODATA.txt
perf report -i $ODATA.data --no-children > $ODATA.nochildren.txt
perf report -i $ODATA.data --call-graph=no > $ODATA.nocg.txt
perf report -i $ODATA.data -C 0-62 > $ODATA.irqonly.txt

for sym in _raw_spin_lock __nf_conntrack_find_get do_epoll_ctl __inet_lookup_established  tcp_ack  tcp_recvmsg_locked  tcp_clean_rtx_queue.constprop.0 fdget __raw_spin_lock_irqsave 
do
	perf annotate -i $ODATA.data -s $sym --vmlinux $VMLINUX > $sym.annotate
done
