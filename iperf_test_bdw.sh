#!/bin/bash -x

#Usage:
#  Start as server
#  ./iperf_test_bdw.sh s
# Start as client
#  ./iperf_test_bdw.sh

ROLE=${1:-"c"}

HOST=192.168.2.1

if [ $ROLE == "s" ]
then
  # Run as server
  echo "staring server"
  iperf3 -s -p 6800
else
  #Run as client
  echo "staring server"
  iperf3 -c $HOST  -p 6800 -t 20

fi
