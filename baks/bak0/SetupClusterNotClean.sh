for arg in {1..10} ; do
    echo "hugo_"$arg
    sleep 2
    date "+H%M%Y"
done


HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)

ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"
SECS=3

SSH="ssh -i $ID_RSA root@$h "

STORM_BASE_CLS="/tmp/hmcl/storm/"
STORM_HOME_CLS="$STORM_BASE_CLS/apache-storm-0.10.0-SNAPSHOT"
STORM_ZIP="apache-storm-0.10.0-SNAPSHOT.zip"

CMDS=("$SSH mkdir -p $STORM_BASE_CLS" # create dir
    scp_fn "/Users/hlouro/Apache/Dev/GitHub/hmcl/storm-apache/storm-dist/binary/target_hwx_HDP-2.3.40/$STORM_ZIP" $STORM_BASE_CLS  # copy zip
    $SSH "unzip $STORM_BASE_CLS/STORM_ZIP"    # unzip
    yaml_copy_bak_mv_fn     #copy proper yaml file
    )


yaml_copy_bak_mv_fn(){
    YAML_TEST_FILE="storm_local_HDP-2.3.40.yaml"
    YAML_DIR_LOCAL="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Yaml/"
    YAML_DIR_CLS="$STORM_HOME_CLS/conf/"

    echo "Backing up " $YAML_DIR_CLS/storm.yaml
    $SSH cp $YAML_DIR_CLS/storm.yaml $YAML_DIR_CLS/storm.yaml.bak

    echo "Copying "  $YAML_DIR_LOCAL/$YAML_TEST_FILE to $YAML_DIR_CLS/$YAML_TEST_FILE 
    scp_fn $YAML_DIR_LOCAL/$YAML_TEST_FILE $YAML_DIR_CLS

    echo "Replacing " $YAML_DIR_CLS/storm.yaml " with " $YAML_DIR_CLS/$YAML_TEST_FILE
    $SSH cp $YAML_DIR_CLS/$YAML_TEST_FILE $YAML_DIR_CLS/storm.yaml
    echo
}

scp_fn(){
    $FROM=$1
    $TO=$2
    SCP="scp -i $ID_RSA $FROM root@$h:$TO"
    echo "Executing " $SCP
    $SCP
}

start_supervisors_fn() {
    echo "Starting supervisor at "
    $STORM_HOME_CLS/bin/storm supervisor &
    sleep $SECS
}

for h in "${HOSTS[@]}"
do
    echo $h
    for c in "${CMDS[@]}"
    do
        echo "Executing " $c
        exec 

        ssh -i $ID_RSA root@$h
        sleep SECS
    done
    do
        echo $c
        
        ssh -i $ID_RSA root@$h
        sleep SECS
    done
done




==========

SSH_CMDS=("mkdir -p /tmp/hmcl/storm"
    "unzip /tmp/hmcl/storm/apache-storm-0.10.0-SNAPSHOT.zip"
    C3)

SCP="scp -i $ID_RSA $FROM root@$h:$TO"

"${array[@]}"

for h in "${HOSTS[@]}"
do
    echo $h
done


for h in "${HOSTS[@]}"
do
    echo $h
    for c in "${CMDS[@]}"
    do
        echo $c
    done
done
