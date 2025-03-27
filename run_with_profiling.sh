#!/bin/bash -x

CONF=conf1
CONF=conf4
CONF=conf6
CONF=conf10
RUN_SERVER_SCRIPT=./run_server_$CONF.sh
RUN_CLIENT_SCRIPT="./run_client_$CONF.sh 3600"
WAIT_UNTIL_STABLE=120

DEVICE=ens6f0d1
rm -rf $CONF
mkdir $CONF

# launch server 
$RUN_SERVER_SCRIPT &
server_pid=$!
sleep 5

# launch client
ssh -o ServerAliveInterval=30 root@192.168.1.1 "cd /root/neper && $RUN_CLIENT_SCRIPT" &
client_pid=$!

sleep $WAIT_UNTIL_STABLE 

cd $CONF

# collect htop
for i in $(seq 10)
do
  echo q | htop | aha --black --line-fix > htop.$CONF.$i.html
  sleep 2
done
grep Avg ./*.html | awk '{print $8}' | sort | tail -6 | head -1 > htop.$CONF.cpu_avg_median.txt

sleep 20


# collect network stats
sar -n DEV --iface=$DEVICE 2 10 | tee sar.$CONF.log

sleep 20

# collect perf record
PERF_ODATA=perf.$CONF.cg
perf record -o $PERF_ODATA.data -m 8M -ag -e cycles:P,instructions:P --call-graph=dwarf,512 -F 199 --sample-cpu --kcore sleep 20

sleep 20

# collect emon 
EMON_DURATION=60
EMON_ODATA=emon.$CONF
config_file=edp_config.txt

/opt/intel/sep/sepdk/src/rmmod-sep
/opt/intel/sep/sepdk/src/insmod-sep
source /opt/intel/sep/sep_vars.sh
sleep 5

emon -collect-edp -f $EMON_ODATA.data &
sleep $EMON_DURATION
emon -stop

######### profiling done, shutdown server
kill -9 $client_pid
kill -9 $server_pid
# no need to kill at client, since it leaves once server is killed
pkill tcp_rr


######## emon post process
function generate_edp_config {
    emon_dat=$1.data
    xslx_output=$1.xslx
    rm $config_file
    touch $config_file
    echo "PYTHON_PATH=/usr/bin/python" >> $config_file
    echo "EMON_DATA=${emon_dat}" >> $config_file
    echo "OUTPUT=${xslx_output}" >> $config_file
    echo "VIEW=\"--socket-view --core-view --thread-view --uncore-view\"" >> $config_file
}

generate_edp_config $EMON_ODATA
emon -process-pyedp $config_file
rm -rf *.csv
####### perf post process
cd $PERF_ODATA.data
perf report -i data --call-graph=no --no-children > $PERF_ODATA.nocg.txt
perf report -i data --no-children > $PERF_ODATA.nochildren.txt

perf report -i data --call-graph=no --no-children -C 0-15 > $PERF_ODATA.nocg.c0-15.txt
perf report -i data --no-children -C 0-15 > $PERF_ODATA.nochildren.c0-15.txt
