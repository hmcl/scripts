#!/usr/bin/env bash

HOST=172.18.128.67

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"

STORM_BASE_CLUSTER="/tmp/hmcl/storm2/"
STORM_HOME_CLUSTER="$STORM_BASE_CLUSTER/apache-storm-0.10.0-SNAPSHOT/"

TPLGY_NAME_PREFIX="wct_hmcl_c2_"
NUM_TPLGYS=200

set_cmd_print_exec_fn() {
    CMD=$1
    echo " -> Executing " $CMD
    $CMD
    unset CMD
#    sleep $SECS
}

ssh_exec_fn(){
    set_cmd_print_exec_fn "ssh -i $ID_RSA root@$HOST $1"
}

deploy_topology_fn() {
    TPLGY_NAME=$1
    set_cmd_print_exec_fn "$STORM_HOME_CLUSTER/bin/storm jar $STORM_HOME_CLUSTER/examples/storm-starter/storm-starter-topologies-0.10.0-SNAPSHOT.jar storm.starter.WordCountTopology $TPLGY_NAME -c topology.workers=1 -c topology.debug=false"
}

kill_topology_fn() {
    TPLGY_NAME=$1
    set_cmd_print_exec_fn "$STORM_HOME_CLUSTER/bin/storm kill $TPLGY_NAME"
#    sleep $SECS
}

for ((i=0; i<NUM_TPLGYS; i++)); do
    deploy_topology_fn $TPLGY_NAME_PREFIX$i
#    kill_topology_fn $TPLGY_NAME_PREFIX$i
done