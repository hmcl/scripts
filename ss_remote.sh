#!/usr/bin/env bash

#HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64 172.18.128.67)
HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)
#HOSTS=(172.18.128.63 172.18.128.64)
#HOSTS=(172.18.128.62 172.18.128.63 172.18.128.64)
#HOSTS=(172.18.128.67)

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"
SECS=1

MAX_CLUSTER_ID=0   # cluster ids go from 0 to $MAX_CLUSTER_ID

STORM_BASE_CLUSTER="/tmp/hmcl/storm"
STORM_VERSION="apache-storm-0.10.0-SNAPSHOT/"
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
#    echo "nohup $STORM_BASE_CLUSTER_I/bin/storm supervisor 2>&1 > $STORM_BASE_CLUSTER_I/logs/supervisor.nohup.log &"
    ssh_exec_fn "nohup $STORM_BASE_CLUSTER_I/bin/storm supervisor 2>&1 > $STORM_BASE_CLUSTER_I/logs/supervisor.nohup.log &"
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
    if [ "$PID" ]; then
        ssh_exec_fn "kill -9 $PID"
        unset PID
    else
        echo "Supervisor already killed"
    fi
}

kill_workers_fn() {
    PID=`check_workers_fn | grep -v grep  | awk '{print $2}'`
    echo $PID
    if [ "$PID" ]; then
        ssh_exec_fn "kill -9 $PID"
        unset PID
    else
        echo "Worker already killed"
    fi
}

list_logs_fn() {
    ssh_exec_fn "ls -la $STORM_BASE_CLUSTER_I/logs"
}

list_all_logs_exclude_workers_fn() {
    ssh_exec_fn "find $STORM_BASE_CLUSTER_I/logs -name '*.*' | grep -v wct"
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

archive_files() {
    DIR=$1

    ssh_exec_fn "mkdir /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/$DIR"
    ssh_exec_fn "mkdir /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mkdir /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mkdir /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"

    ssh_exec_fn "mv -f /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/*.log /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mv -f /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/*.log /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mv -f /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/*.log /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mv -f /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/*.log /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"

    ssh_exec_fn "mv -f /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/*.log.* /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mv -f /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/*.log.* /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mv -f /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/*.log.* /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mv -f /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/*.log.* /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"

    ssh_exec_fn "mv -f /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/wct* /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mv -f /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/wct* /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mv -f /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/wct* /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "mv -f /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/wct* /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"

    ssh_exec_fn "ls /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "ls /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "ls /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
    ssh_exec_fn "ls /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
}

cleanup(){
#    kill_supervisors_fn
#    kill_workers_fn
    remove_storm_local
    remove_logs
}

scp_zip_logs_fn() {
    RUN="$1"
    FROM="$STORM_BASE_CLUSTER_I/logs/$RUN.zip"
    TO="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Logs/$RUN"
    mkdir $TO
    set_cmd_print_exec_fn "scp -i $ID_RSA root@$HOST:$FROM $TO/$HOST"_"$RUN.zip"
}

build_storm_base_cluster_name_fn() {
    i=$1
    if [ $i == 0 ]; then

        STORM_BASE_CLUSTER_I="$STORM_BASE_CLUSTER"/"$STORM_VERSION"
    else
        STORM_BASE_CLUSTER_I="$STORM_BASE_CLUSTER$i"/"$STORM_VERSION"
    fi
}

for HOST in "${HOSTS[@]}"
do
    for ((i=0; i<=MAX_CLUSTER_ID; i++));
    do
        # This function must always be uncommented
        build_storm_base_cluster_name_fn $i

#        start_supervisors_fn
#        list_all_logs_exclude_workers_fn
        list_logs_fn
    done
#    archive_files "run9_1x400_ts_clean_nsc"
#scp_zip_logs_fn "run4_4x200_ts_clean"

    check_storm_fn

#    check_supervisors_fn

#    kill_supervisors_fn
#    remove_storm_local
#    remove_logs

#    check_workers_fn
#    kill_workers_fn

#    print_java_home_fn
#    list_logs_fn
#    mv_logs_to_fn
#    list_logs_fn
#    list_jdk_2fn
#    set_jdk_fn
#    cleanup
    echo "---"
done