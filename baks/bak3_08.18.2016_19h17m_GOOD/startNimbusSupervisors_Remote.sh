#!/usr/bin/env bash

HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"
SECS=10

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
    set_cmd_print_exec_fn "nohup $STORM_HOME_CLUSTER/bin/storm supervisor & 2>&1 > STORM_HOME_CLUSTER/logs/supervisor.nohup.log"
}

start_nimbus_fn() {
    set_cmd_print_exec_fn "nohup $STORM_HOME_CLUSTER/bin/storm nimbus & 2>&1 > STORM_HOME_CLUSTER/logs/nimbus.nohup.log"
}

check_supervisors_fn() {
    ssh_exec_fn "ps -ef | grep -v grep | grep supervisor "
}

check_workers_fn() {
    ssh_exec_fn "ps -ef | grep -v grep | grep storm | grep worker"
}

check_nimbus_fn() {
    ssh_exec_fn "ps -ef | grep -v grep | grep storm | grep worker"
}


kill_supervisors_fn() {
    PID=`check_supervisors_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    ssh_exec_fn "kill -9 $PID"
}

kill_workers_fn() {
    PID=`check_workers_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    ssh_exec_fn "kill -9 $PID"
}

kill_nimbus_fn() {
    PID=`check_nimbus_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    ssh_exec_fn "kill -9 $PID"
}

list_logs_fn() {
    ssh_exec_fn "ls -la $STORM_HOME_CLUSTER/logs"
}

for HOST in "${HOSTS[@]}"
do
#    start_supervisors_fn
#    check_supervisors_fn
    kill_supervisors_fn
#    check_workers_fn
#    kill_workers_fn
#    print_java_home_fn
#    list_logs_fn
#    list_jdk_fn
#    set_jdk_fn
    echo "---"
done