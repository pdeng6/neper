#!/bin/bash -x

HOST=192.168.100.1

ulimit -n 999999
./tcp_rr -4 -T 600 -F 30000 -l 60 -c -H $HOST

