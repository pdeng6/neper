#!/bin/bash -x

HOST=ens6f0np0

sar.sysstat -n DEV --iface=$HOST 2 | tee sar.log
