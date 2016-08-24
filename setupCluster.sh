#!/usr/bin/env bash
# HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)
#HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)
#HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64 172.18.128.67)
#HOSTS=(172.18.128.62 172.18.128.63 172.18.128.64 172.18.128.67)
HOSTS=(172.18.128.67)

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"

MAX_CLUSTER_ID=3   # cluster ids go from 0 to $MAX_CLUSTER_ID

STORM_ZIP="apache-storm-0.10.0-SNAPSHOT.zip"        # name of the zip file
STORM_LEAF_CLUSTER="apache-storm-0.10.0-SNAPSHOT"   # name of the last path element of the storm installation in the cluster

STORM_BASE_CLUSTER="/grid/3/hmcl/storm"

STORM_HOME_CLUSTER="$STORM_BASE_CLUSTER/$STORM_LEAF_CLUSTER/"

STORM_BASE_ROOT_CLUSTER="/grid/3/hmcl/storm0/"  # used only to reuse zip file -> unzip_to_dir_fn


set_cmd_print_exec_fn() {
    CMD=$1
    echo " -> Executing " $CMD
    $CMD
    unset CMD
}

scp_fn(){
    FROM=$1
    TO=$2
    set_cmd_print_exec_fn "scp -i $ID_RSA $FROM root@$HOST:$TO"
    unset FROM
    unset TO
}

ssh_exec_fn(){
    set_cmd_print_exec_fn "ssh -i $ID_RSA root@$HOST $1"
}

create_dir_fn() {
    ssh_exec_fn "mkdir -p $1"
}

copy_zip_fn(){
    scp_fn "/Users/hlouro/Apache/Dev/GitHub/hmcl/storm-apache/storm-dist/binary/target_hwx_HDP-2.3.40/$STORM_ZIP" "$1"
}

unzip_fn(){
    ssh_exec_fn "cd $1; unzip $1/$STORM_ZIP"
}

unzip_to_dir_fn(){
    ssh_exec_fn "cd $STORM_BASE_ROOT_CLUSTER; unzip $STORM_BASE_ROOT_CLUSTER/$STORM_ZIP -d $STORM_BASE_CLUSTER"
}

yaml_copy_bak_mv_fn(){
    # Local
    YAML_DIR_LOCAL="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Yaml/"
    YAML_TEST_FILE="storm_cluster_HDP-2.3.40_"$1".yaml"

    # Cluster
    YAML_DIR_CLUSTER="$2/conf/"

    ssh_exec_fn "cp $YAML_DIR_CLUSTER/storm.yaml $YAML_DIR_CLUSTER/storm.yaml.bak"  # bak yaml

    scp_fn "$YAML_DIR_LOCAL/$YAML_TEST_FILE" "$YAML_DIR_CLUSTER"    # copy configured YAML from local to cluster

    ssh_exec_fn "cp $YAML_DIR_CLUSTER/$YAML_TEST_FILE $YAML_DIR_CLUSTER/storm.yaml"  # replace storm.yaml with configured yaml
}

yaml_cat_fn(){
    YAML_DIR_CLUSTER="$STORM_HOME_CLUSTER/conf/"
    ssh_exec_fn "cat $YAML_DIR_CLUSTER/storm.yaml"
}

#yaml_copy_revert_fn(){
##    YAML_TEST_FILE="storm_cluster_HDP-2.3.40.yaml"
#    YAML_TEST_FILE="storm_cluster_HDP-2.3.40_1.yaml"
##    YAML_TEST_FILE="storm_cluster_HDP-2.3.40_2.yaml"
##    YAML_TEST_FILE="storm_cluster_HDP-2.3.40_3.yaml"
#    YAML_DIR_LOCAL="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Yaml/"
#    YAML_DIR_CLUSTER="$STORM_HOME_CLUSTER/conf/"
#
#    ssh_exec_fn "cp $YAML_DIR_CLUSTER/storm.yaml.bak $YAML_DIR_CLUSTER/storm.yaml"  # bak yaml
#    ssh_exec_fn "rm $YAML_DIR_CLUSTER/$YAML_TEST_FILE"
#}

uninstall_storm_cluster_fn(){
    ssh_exec_fn "rm -rf $STORM_HOME_CLUSTER"
#    ssh_exec_fn "rm -rf $STORM_BASE_CLUSTER/$STORM_ZIP"
}

list_dir_fn() {
    ssh_exec_fn "ls -la $1"
}

find_all_dir_fn() {
    ssh_exec_fn "find $1 -name '*.*' | grep -P '\bconf\b'"
}

install(){
    create_dir_fn "$2"

    copy_zip_fn "$2"

    unzip_fn "$2"
#    unzip_to_dir_fn "$2"

    yaml_copy_bak_mv_fn "$1" "$2/$STORM_LEAF_CLUSTER"
}

## TODO
#setup_scripts_fn() {
#    FROM="$YAML_DIR_LOCAL/$YAML_TEST_FILE"
#    TO="$YAML_DIR_CLUSTER"
#    scp_fn
#}


build_storm_base_cluster_name_fn() {
    i=$1
    STORM_BASE_CLUSTER_I="$STORM_BASE_CLUSTER$i"/"$STORM_VERSION"
    echo "$STORM_BASE_CLUSTER_I"
}

for HOST in "${HOSTS[@]}"
do
    echo "$HOST"
    for ((i=0; i<=MAX_CLUSTER_ID; i++));
    do
        # This function must always be uncommented
        build_storm_base_cluster_name_fn $i

        list_dir_fn "$STORM_BASE_CLUSTER_I//$STORM_LEAF_CLUSTER/conf"

#        install "$i" "$STORM_BASE_CLUSTER_I"
    done

# Probably I don't need this anymore. Check
#        start_supervisors_fn
#        list_all_logs_exclude_workers_fn
#        list_logs_fn
#    list_hmcl_fn
#    install
#    uninstall_storm_cluster_fn
#    yaml_copy_bak_mv_fn
#    yaml_copy_revert_fn
#     yaml_cat_fn
    echo "-----"
done