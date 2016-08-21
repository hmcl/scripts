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

scp_fn(){
    RUN="$1"
    FROM="$STORM_BASE_CLUSTER_I/logs/$RUN/nimbus.log"
    TO="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Logs/$RUN"

    set_cmd_print_exec_fn "scp -i $ID_RSA root@$HOST:$FROM $TO"

    unset RUN
    unset FROM
    unset TO
}

scp_run_logs_fn(){
    scp_fn $1
}

scp_kill_logs_fn(){
    scp_fn $1
}

scp_logs_fn(){
    NAME=$1
#    NAME="run2_4x200_ts_run"
    scp_run_logs_fn $NAME
    scp_kill_logs_fn $NAME"_kill"
    break
}

zip_logs_fn(){
    RUN=$1
    PATH="$STORM_BASE_CLUSTER_I/logs/$RUN"
    ssh_exec_fn "/usr/bin/zip -r $PATH.zip $PATH"
    break
}

scp_zip_logs_fn() {
    RUN="$1"
    FROM="$STORM_BASE_CLUSTER_I/logs/$RUN.zip"
    TO="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Logs/$RUN"
    mkdir $TO
    set_cmd_print_exec_fn "scp -i $ID_RSA root@$HOST:$FROM $TO/$HOST"_"$RUN.zip"
    break
}

start_nimbus_fn() {
    ssh_exec_fn "nohup $1/bin/storm nimbus 2>&1 > $1/logs/nimbus.nohup.log &"
}

check_nimbus_fn() {
    ssh_exec_fn "ps -ef | grep -v grep | grep storm | grep backtype.storm.daemon.nimbus"
    break
}

list_logs_nimbus_fn() {
    ssh_exec_fn "ls -la $STORM_BASE_CLUSTER_I/logs"
}

get_logs_nimbus_fn() {
    ssh_exec_fn "ls -la $STORM_BASE_CLUSTER_I/logs"
}

tail_logs_nimbus_fn() {
    ssh_exec_fn "tail -f $STORM_BASE_CLUSTER_I/logs"
    break
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
    break;
}

kill_nimbus_fn() {
    PID=`check_nimbus_fn | grep -v grep  | awk '{print $2}'`
    if [ "$PID" ]; then
        ssh_exec_fn "kill -9 $PID"
        unset PID
    else
        echo "Nimbus already killed"
    fi
}

remove_storm_local() {
    ssh_exec_fn "rm -rf /root/storm-local; rm -rf /root/storm-local-1; rm -rf /root/storm-local-2; rm -rf /root/storm-local-3;"
}

cleanup(){
    kill_nimbus_fn
    remove_storm_local
    remove_logs
    break
}

archive_files() {
    DIR="run6_4x100_ts_clean_nsc"

    ssh_exec_fn "mkdir /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/$DIR;"
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
    break
}

#INDEX must be zero
for ((i=0; i<=MAX_CLUSTER_ID; i++));
do
    if [ $i == 0 ]; then

        STORM_BASE_CLUSTER_I="$STORM_BASE_CLUSTER"/"$STORM_VERSION"
    else
        STORM_BASE_CLUSTER_I="$STORM_BASE_CLUSTER$i"/"$STORM_VERSION"
    fi

    echo "Starting nimbus on  $STORM_BASE_CLUSTER_I"

#    start_nimbus_fn $STORM_BASE_CLUSTER_I
    check_nimbus_fn
#    kill_nimbus_fn
#    archive_files
#    list_logs_nimbus_fn
#    tail_logs_nimbus_fn
#    remove_storm_local
#    remove_logs
#    zip_logs_fn "run4_4x200_ts_clean"
#    scp_zip_logs_fn "run4_4x200_ts_clean"
#    cleanup
#    scp_logs_fn "run3_4x200_ts_spsoom"
    echo "---"
done
#    echo "ls -la $STORM_BASE_CLUSTER_I;"
