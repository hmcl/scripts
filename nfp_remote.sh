#!/usr/bin/env bash

HOST=172.18.128.67

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"

set_cmd_print_exec_fn() {
    CMD=$1
    echo " -> Executing " $CMD
    $CMD
    unset CMD
}

ssh_exec_fn(){
    set_cmd_print_exec_fn "ssh -i $ID_RSA root@$HOST $1"
}

nimbus_find_pattern_fn() {
    if [ "$1" ]; then
        P="$1";
    else
        P="\"(.*?(Uploading|Finished uploading|Activating|Setting new assignment.*?:))\"";
    fi
    ssh_exec_fn "
        grep -Po "$P" /tmp/hmcl/storm//apache-storm-0.10.0-SNAPSHOT//logs/nimbus.log | tail;
        grep -Po "$P" /tmp/hmcl/storm1//apache-storm-0.10.0-SNAPSHOT//logs/nimbus.log | tail;
        grep -Po "$P" /tmp/hmcl/storm2//apache-storm-0.10.0-SNAPSHOT//logs/nimbus.log | tail;
        grep -Po "$P" /tmp/hmcl/storm3//apache-storm-0.10.0-SNAPSHOT//logs/nimbus.log | tail
    "
}

nimbus_find_pattern_fn
