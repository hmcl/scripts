#!/usr/bin/env bash

HOST=172.18.128.67

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"

MAX_CLUSTER_ID=0    # cluster ids go from 0 to $MAX_CLUSTER_ID

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
    echo $1
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

zip_logs_exec_fn(){
    RUNS=("$1")
    CMD="$2"
    len=${#RUNS[@]}
    for (( j=0; j<${len}; j++));
    do
      RUN_PATH="$STORM_BASE_CLUSTER_I/logs/${RUNS[$j]}"
      ssh_exec_fn $CMD
    done
}

zip_logs_create_fn(){
#    zip_logs_exec_fn $1 "/usr/bin/zip -r $RUN_PATH.zip $RUN_PATH"
    RUNS=($1)
    len=${#RUNS[@]}
    for (( j=0; j<${len}; j++));
    do
      RUN_PATH="$STORM_BASE_CLUSTER_I/logs/${RUNS[$j]}"
      ssh_exec_fn "/usr/bin/zip -r $RUN_PATH.zip $RUN_PATH"
    done
}

zip_logs_scp_fn() {
#    zip_logs_exec_fn $1

    RUNS=($1)
    len=${#RUNS[@]}
    for (( j=0; j<${len}; j++));
    do
        RUN="${RUNS[$j]}"
        FROM="$STORM_BASE_CLUSTER_I/logs/$RUN.zip"
        TO="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Logs/$RUN/$STORM_I"
        mkdir -p $TO
       set_cmd_print_exec_fn "scp -i $ID_RSA root@$HOST:$FROM $TO/$RUN.zip"
    done
}

start_nimbus_fn() {
#    echo "nohup $1/bin/storm nimbus 2>&1 > $1/logs/nimbus.nohup.log &"
    ssh_exec_fn "nohup $1/bin/storm nimbus 2>&1 > $1/logs/nimbus.nohup.log &"
}

check_nimbus_fn() {
    ssh_exec_fn "ps -ef | grep -v grep | grep storm | grep backtype.storm.daemon.nimbus"
    break
}

list_logs_nimbus_fn() {
    ssh_exec_fn "ls -la $STORM_BASE_CLUSTER_I/logs"
}

list_all_logs_nimbus_fn() {
    ssh_exec_fn "find $STORM_BASE_CLUSTER_I/logs -name '*.*' | grep clean"
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
        rm -f $STORM_BASE_CLUSTER_I//logs/*.log;
        rm -f $STORM_BASE_CLUSTER_I//logs/*.log.*;
        rm -f $STORM_BASE_CLUSTER_I//logs/wct*;
    "
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
    RUN=$1

    ssh_exec_fn "mkdir $STORM_BASE_CLUSTER_I//logs/$RUN;"

    ssh_exec_fn "mv -f $STORM_BASE_CLUSTER_I//logs/*.log $STORM_BASE_CLUSTER_I//logs/$RUN;"
    ssh_exec_fn "mv -f $STORM_BASE_CLUSTER_I//logs/*.log.* $STORM_BASE_CLUSTER_I//logs/$RUN;"
    ssh_exec_fn "mv -f $STORM_BASE_CLUSTER_I//logs/wct* $STORM_BASE_CLUSTER_I//logs/$RUN;"

    ssh_exec_fn "ls $STORM_BASE_CLUSTER_I//logs/$RUN;"

    SCPT_DIR="/tmp/hmcl/scripts/"
    ssh_exec_fn "mkdir -p $SCPT_DIR/logs/$RUN && mv -f $SCPT_DIR/logs/*.log $SCPT_DIR/logs/$RUN"
}

unzip_nimbus_locally() {
    RUN=run8_4x100_ts_clean_nsc
    unzip $RUN.zip;
    mv tmp/hmcl/storm3/apache-storm-0.10.0-SNAPSHOT/logs/$RUN/nimbus.log ./;
    rm -rf tmp/;
}

get_excel_column() {
    PU=".*Uploading"
    echo "Patterns matching = " `grep -Eo "$PU" nimbus.log | awk '{print $2}' | wc -l`
    grep -Eo "$PU" nimbus.log |  $2} | pbcopy
}

build_storm_base_cluster_name_fn() {
    i=$1
    if [ $i == 0 ]; then
        STORM_I="storm"
        STORM_BASE_CLUSTER_I="$STORM_BASE_CLUSTER"/"$STORM_VERSION"
    else
        STORM_I="storm$i"
        STORM_BASE_CLUSTER_I="$STORM_BASE_CLUSTER$i"/"$STORM_VERSION"
    fi
}

#INDEX must be zero
for ((i=0; i<=MAX_CLUSTER_ID; i++));
do
    build_storm_base_cluster_name_fn $i

    echo "Starting nimbus on  $STORM_BASE_CLUSTER_I"

#    zip_logs_create_fn "run4_4x200_ts_clean run5_4x100_ts_clean_nsc run6_4x100_ts_clean_nsc"
#    zip_logs_scp_fn "run4_4x200_ts_clean run5_4x100_ts_clean_nsc run6_4x100_ts_clean_nsc"
#    zip_logs_create_fn "run9_1x400_ts_clean_nsc"
#    zip_logs_scp_fn "run9_1x400_ts_clean_nsc"

#    start_nimbus_fn $STORM_BASE_CLUSTER_I
#    check_nimbus_fn
#    kill_nimbus_fn
#    archive_files "run9_1x400_ts_clean_nsc"
#    list_all_logs_nimbus_fn
    list_logs_nimbus_fn
#    tail_logs_nimbus_fn
#    remove_storm_local
#    remove_logs
#    zip_logs_fn "run4_4x200_ts_clean run5_4x100_ts_clean_nsc run6_4x100_ts_clean_nsc"
#    zip_logs_scp_fn "run4_4x200_ts_clean"
#    cleanup
#    scp_logs_fn "run3_4x200_ts_spsoom"
    echo "---"
done
#    echo "ls -la $STORM_BASE_CLUSTER_I;"
