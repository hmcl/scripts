ID_RSA="/Users/hlouro/Hortonworks/Tasks/KafkaSpout/Performance/ssh/172.18.128.67/id_rsa"
ssh_exec_fn(){
    HOST="$1"
    CMD="$2"
	echo "ssh -i $ID_RSA root@$HOST $CMD"
#    ./set_cmd_print_exec_fn.sh "ssh -i $ID_RSA root@$HOST $CMD"
    ssh -i $ID_RSA root@$HOST $CMD
}

ssh_exec_fn $1 $2
