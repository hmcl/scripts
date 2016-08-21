#!/usr/bin/env bash

#HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64 172.18.128.67)
HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)
#HOSTS=(172.18.128.63 172.18.128.64)
#HOSTS=(172.18.128.62 172.18.128.63 172.18.128.64)
#HOSTS=(172.18.128.67)

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"
SECS=1

STORM_BASE_CLUSTER="/tmp/hmcl/storm/"
#STORM_BASE_CLUSTER="/tmp/hmcl/storm1/"
#STORM_BASE_CLUSTER="/tmp/hmcl/storm2/"
#STORM_BASE_CLUSTER="/tmp/hmcl/storm3/"

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
#    ssh -i $ID_RSA root@$HOST "ls -la"
#    ssh -i $ID_RSA root@$HOST "nohup $STORM_HOME_CLUSTER/bin/storm supervisor 2>&1 > $STORM_HOME_CLUSTER/logs/supervisor.nohup.log &"
    ssh_exec_fn "nohup $STORM_HOME_CLUSTER/bin/storm supervisor 2>&1 > $STORM_HOME_CLUSTER/logs/supervisor.nohup.log &"
#    ssh_exec_fn "$STORM_HOME_CLUSTER/bin/storm supervisor 2>&1 > $STORM_HOME_CLUSTER/logs/supervisor.nohup.log"
#    ssh_exec_fn "$STORM_HOME_CLUSTER/bin/storm supervisor"
#    $PID=`ssh_exec_fn "nohup $STORM_HOME_CLUSTER/bin/storm supervisor 2>&1 > $STORM_HOME_CLUSTER/logs/supervisor.nohup.log &"`
#    echo "Killing $PID"
#    kill -2 $PID
}

check_supervisors_fn() {
    ssh_exec_fn "ps -ef | grep -v grep | grep backtype.storm.daemon.supervisor"
}

check_workers_fn() {
#    ssh_exec_fn "ps -ef | grep -v grep | grep storm | grep worker"
    ssh_exec_fn "ps -ef | grep -v grep | grep storm | grep backtype.storm.daemon.worker"
}

check_storm_fn() {
    ssh_exec_fn "ps -ef | grep -v grep | grep storm"
}

kill_supervisors_fn() {
    PID=`check_supervisors_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    ssh_exec_fn "kill -9 $PID"
##    ssh_exec_fn "kill -9 `ps -ef | grep -v grep | grep supervisor | awk '{print $2}'`"
#    ssh_exec_fn "PID='ps -ef | grep -v grep | grep supervisor | awk '{print $2}''"
#    ssh_exec_fn "kill -9 $PID"
#    unset PID
}

kill_workers_fn() {
    PID=`check_workers_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    ssh_exec_fn "kill -9 $PID"
}

list_logs_fn() {
    ssh_exec_fn "ls -la $STORM_HOME_CLUSTER/logs"
}

mv_logs_to_fn() {
    TO="$STORM_HOME_CLUSTER/logs/$1"
    mkdir -p $TO
    ssh_exec_fn "mv $STORM_HOME_CLUSTER/logs/*.log $TO"
}

list_jdk_fn() {
    ssh_exec_fn "ls -la /usr/jdk64/jdk1.8.0_60"
}

set_jdk_fn() {
    ssh_exec_fn "export JAVA_HOME=/usr/jdk64/jdk1.8.0_60; export PATH=$JAVA_HOME/bin:$PATH"
}

print_java_home_fn() {
    ssh_exec_fn "echo {$JAVA_HOME}"
}

remove_storm_local() {
    ssh_exec_fn "rm -rf /root/storm-local; rm -rf /root/storm-local-1; rm -rf /root/storm-local-2; rm -rf /root/storm-local-3;"
}

remove_logs() {
    ssh_exec_fn "
        rm -f /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/*.log;
        rm -f /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/*.log;
        rm -f /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/*.log;
        rm -f /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/*.log;

        rm -f /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/wct*;
        rm -f /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/wct*;
        rm -f /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/wct*;
        rm -f /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/wct*;
    "
}

cleanup(){
    kill_supervisors_fn
    kill_workers_fn
    remove_storm_local
    remove_logs
}

for HOST in "${HOSTS[@]}"
do
    check_storm_fn

#    start_supervisors_fn
#    check_supervisors_fn

#    kill_supervisors_fn
    remove_storm_local
    remove_logs

#    check_workers_fn
#    kill_workers_fn

#    print_java_home_fn
#    list_logs_fn
#    mv_logs_to_fn
#    list_logs_fn
#    list_jdk_fn
#    set_jdk_fn
    echo "---"
done

#STORM_BASE_CLUSTER="/tmp/hmcl/storm/";
#STORM_HOME_CLUSTER="$STORM_BASE_CLUSTER/apache-storm-0.10.0-SNAPSHOT/";
#$STORM_HOME_CLUSTER/bin/storm supervisor &
#
#11512:q