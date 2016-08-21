#!/usr/bin/env bash

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"
SECS=1

STORM_BASE_CLUSTER="/tmp/hmcl/storm/"
STORM_HOME_CLUSTER="$STORM_BASE_CLUSTER/apache-storm-0.10.0-SNAPSHOT/"
STORM_ZIP="apache-storm-0.10.0-SNAPSHOT.zip"

set_cmd_print_exec_fn() {
    CMD=$1
    echo " -> Executing " $CMD
    $CMD
    unset CMD
    sleep $SECS
}

scp_fn(){
    set_cmd_print_exec_fn "scp -i $ID_RSA $FROM root@$HOST:$TO"
    unset FROM
    unset TO
}

#HOST=$1
#FROM=$2
#TO=$3

HOST="172.18.128.67"
FROM="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Scripts/startTopologies.sh"
TO="$STORM_HOME_CLUSTER/bin"

scp_fn