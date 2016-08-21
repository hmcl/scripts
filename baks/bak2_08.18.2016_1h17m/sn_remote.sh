#!/usr/bin/env bash

HOST=172.18.128.67

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"

MAX_CLUSTER_ID=3    # cluster ids go from 0 to $MAX_CLUSTER_ID

STORM_BASE_CLUSTER="/tmp/hmcl/storm"
STORM_BASE_CLUSTERS=("/tmp/hmcl/storm/","/tmp/hmcl/storm1/","/tmp/hmcl/storm2/","/tmp/hmcl/storm3/")

STORM_VERSION="apache-storm-0.10.0-SNAPSHOT/"
#STORM_HOME_CLUSTER="$STORM_BASE_CLUSTER/apache-storm-0.10.0-SNAPSHOT/"

set_cmd_print_exec_fn() {
    CMD=$1
    echo " -> Executing " $CMD
    $CMD
    unset CMD
}

ssh_exec_fn(){
    set_cmd_print_exec_fn "ssh -i $ID_RSA root@$HOST $1"
}

start_nimbus_fn() {
    ssh_exec_fn "nohup $1/bin/storm nimbus 2>&1 > $1/logs/nimbus.nohup.log &"
}

check_nimbus_fn() {
    ssh_exec_fn "ps -ef | grep -v grep | grep storm | grep nimbus"
}

kill_nimbus_fn() {
    PID=`check_nimbus_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    ssh_exec_fn "kill -9 $PID"
    unset PID
}


for ((i=0; i<=MAX_CLUSTER_ID; i++));
do
    if [ $i == 0 ]; then

        STORM_BASE_CLUSTER_I="$STORM_BASE_CLUSTER"/"$STORM_VERSION"
    else
        STORM_BASE_CLUSTER_I="$STORM_BASE_CLUSTER$i"/"$STORM_VERSION"
    fi

    echo "Starting nimbus on  $STORM_BASE_CLUSTER_I"
    start_nimbus_fn $STORM_BASE_CLUSTER_I
#    check_nimbus_fn
#    kill_nimbus_fn
done
#    echo "ls -la $STORM_BASE_CLUSTER_I;"
