#!/usr/bin/env bash

#HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)
HOSTS=(172.18.128.62 172.18.128.63 172.18.128.64)

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"
SECS=1

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

set_alias_fn(){
    ssh_exec_fn "alias grep='grep --color'"
    ssh_exec_fn "alias psef='ps -ef | grep -i'"
}

for HOST in ${HOSTS[@]}
do
    set_alias_fn
done
