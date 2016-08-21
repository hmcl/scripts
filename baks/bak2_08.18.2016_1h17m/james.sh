#!/usr/bin/env bash

HOSTS=(172.18.128.61)

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"
SECS=1

STORM_BASE_CLUSTER="/tmp/hmcl/storm/"
STORM_HOME_CLUSTER="$STORM_BASE_CLUSTER/apache-storm-0.10.0-SNAPSHOT/"

set_cmd_print_exec_fn() {
    CMD=$1
    echo " -> Executing " $CMD
    $CMD
    unset CMD
    sleep $SECS
}

ssh_exec_fn(){
    set_cmd_print_exec_fn "ssh -i $ID_RSA root@$HOST $1"
}

start_supervisors_fn() {
#    ssh -i $ID_RSA root@$HOST "ls -la"         # This works

    ssh -i $ID_RSA root@$HOST "nohup $STORM_HOME_CLUSTER/bin/storm supervisor 2>&1 > $STORM_HOME_CLUSTER/logs/supervisor.nohup.log &"   # Doesn't work

#    ssh_exec_fn "$STORM_HOME_CLUSTER/bin/storm supervisor" # Simplified version also does not work
}

check_supervisors_fn() {
    ssh_exec_fn "ps -ef | grep -v grep | grep supervisor "
}

kill_supervisors_fn() {
    PID=`check_supervisors_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    ssh_exec_fn "kill -9 $PID"
    unset PID
}

for HOST in "${HOSTS[@]}"
do
    start_supervisors_fn
#   check_supervisors_fn
#   kill_supervisors_fn
    echo "---"
done