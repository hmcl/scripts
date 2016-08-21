#!/usr/bin/env bash
# HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)
HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)
#HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64 172.18.128.67)
#HOSTS=(172.18.128.62 172.18.128.63 172.18.128.64 172.18.128.67)
#HOSTS=(172.18.128.61)

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"
SECS=0

STORM_BASE_ROOT_CLUSTER="/tmp/hmcl/storm/"
STORM_BASE_CLUSTER="/tmp/hmcl/storm3/"
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

ssh_exec_fn(){
    set_cmd_print_exec_fn "ssh -i $ID_RSA root@$HOST $1"
}

create_dir_fn() {
    ssh_exec_fn "mkdir -p $STORM_BASE_CLUSTER"
}

copy_zip_fn(){
    FROM="/Users/hlouro/Apache/Dev/GitHub/hmcl/storm-apache/storm-dist/binary/target_hwx_HDP-2.3.40/$STORM_ZIP"
    TO="$STORM_BASE_CLUSTER"
    scp_fn
}

copy_yaml_fn(){
    FROM="$YAML_DIR_LOCAL/$YAML_TEST_FILE"
    TO="$YAML_DIR_CLUSTER"
    scp_fn
}

unzip_fn(){
    ssh_exec_fn "cd $STORM_BASE_CLUSTER; unzip $STORM_BASE_CLUSTER/$STORM_ZIP"
}

unzip_fn_1(){
    ssh_exec_fn "cd $STORM_BASE_ROOT_CLUSTER; unzip $STORM_BASE_ROOT_CLUSTER/$STORM_ZIP -d $STORM_BASE_CLUSTER"
}

yaml_copy_bak_mv_fn(){
    YAML_TEST_FILE="storm_cluster_HDP-2.3.40_3.yaml"
    YAML_DIR_LOCAL="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Yaml/"
    YAML_DIR_CLUSTER="$STORM_HOME_CLUSTER/conf/"

    ssh_exec_fn "cp $YAML_DIR_CLUSTER/storm.yaml $YAML_DIR_CLUSTER/storm.yaml.bak"  # bak yaml

    copy_yaml_fn    # copy configured yaml from local to cluster

    ssh_exec_fn "cp $YAML_DIR_CLUSTER/$YAML_TEST_FILE $YAML_DIR_CLUSTER/storm.yaml"  # replace storm.yaml with configured yaml
}

yaml_copy_revert_fn(){
    YAML_TEST_FILE="storm_cluster_HDP-2.3.40_3.yaml"
    YAML_DIR_LOCAL="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Yaml/"
    YAML_DIR_CLUSTER="$STORM_HOME_CLUSTER/conf/"

    ssh_exec_fn "cp $YAML_DIR_CLUSTER/storm.yaml.bak $YAML_DIR_CLUSTER/storm.yaml"  # bak yaml
    ssh_exec_fn "rm $YAML_DIR_CLUSTER/$YAML_TEST_FILE"
}

uninstall_storm_cluster_fn(){
    ssh_exec_fn "rm -rf $STORM_HOME_CLUSTER"
#    ssh_exec_fn "rm -rf $STORM_BASE_CLUSTER/$STORM_ZIP"
}

list_hmcl_fn() {
    ssh_exec_fn "ls -la /tmp/hmcl"
    ssh_exec_fn "find /tmp/hmcl -name '*.*' | grep -P '\bconf\b'"

}
exec_cmds_fn(){
    create_dir_fn

#    copy_zip_fn

#    unzip_fn
    unzip_fn_1

    yaml_copy_bak_mv_fn
}

## TODO
#setup_scripts_fn() {
#    FROM="$YAML_DIR_LOCAL/$YAML_TEST_FILE"
#    TO="$YAML_DIR_CLUSTER"
#    scp_fn
#}

for HOST in "${HOSTS[@]}"
do
#    list_hmcl_fn
#    exec_cmds_fn
#    uninstall_storm_cluster_fn
    yaml_copy_bak_mv_fn
#    yaml_copy_revert_fn
    echo "-----"
done