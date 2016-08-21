#!/usr/bin/env bash

SECS=0

STORM_BASE_CLUSTER="/tmp/hmcl/storm/"
STORM_HOME_CLUSTER="$STORM_BASE_CLUSTER/apache-storm-0.10.0-SNAPSHOT/"

set_cmd_print_exec_fn() {
    CMD=$1
    echo " -> Executing " $CMD
    $CMD
    unset CMD
    sleep $SECS
}

start_supervisors_fn() {
    set_cmd_print_exec_fn "nohup $STORM_HOME_CLUSTER/bin/storm supervisor 2>&1 > STORM_HOME_CLUSTER/logs/supervisor.nohup.log &"
}

start_nimbus_fn() {
    set_cmd_print_exec_fn "nohup $STORM_HOME_CLUSTER/bin/storm nimbus 2>&1 > STORM_HOME_CLUSTER/logs/nimbus.nohup.log &"
}

check_supervisors_fn() {
    set_cmd_print_exec_fn "ps -ef | grep -v grep | grep supervisor "
}

check_workers_fn() {
    set_cmd_print_exec_fn "ps -ef | grep -v grep | grep storm | grep worker"
}

check_nimbus_fn() {
    set_cmd_print_exec_fn "ps -ef | grep -v grep | grep storm | grep worker"
}


kill_supervisors_fn() {
    PID=`check_supervisors_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    set_cmd_print_exec_fn "kill -9 $PID"
}

kill_workers_fn() {
    PID=`check_workers_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    set_cmd_print_exec_fn "kill -9 $PID"
}

kill_nimbus_fn() {
    PID=`check_nimbus_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    set_cmd_print_exec_fn "kill -9 $PID"
}

list_logs_fn() {
    set_cmd_print_exec_fn "ls -la $STORM_HOME_CLUSTER/logs"
}


    start_nimbus_fn
    start_supervisors_fn
#    check_supervisors_fn
#    kill_supervisors_fn
#    check_workers_fn
#    kill_workers_fn
#    print_java_home_fn
#    list_logs_fn
#    list_jdk_fn
#    set_jdk_fn

STORM_BASE_CLUSTER="/tmp/hmcl/storm/";
STORM_HOME_CLUSTER="$STORM_BASE_CLUSTER/apache-storm-0.10.0-SNAPSHOT/";
"nohup $STORM_HOME_CLUSTER/bin/storm supervisor 2>&1 > STORM_HOME_CLUSTER/logs/supervisor.nohup.log &"

STORM_BASE_CLUSTER="/tmp/hmcl/storm3/";
STORM_HOME_CLUSTER="$STORM_BASE_CLUSTER/apache-storm-0.10.0-SNAPSHOT/";
mkdir $STORM_HOME_CLUSTER/logs;
nohup $STORM_HOME_CLUSTER/bin/storm nimbus 2>&1 > $STORM_HOME_CLUSTER/logs/nimbus.nohup.log &