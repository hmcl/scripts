HOSTS=(172.18.128.61 172.18.128.62 172.18.128.63 172.18.128.64)

fn_1(){
    echo "P11 = " $1
    echo "HOST = " $HOST
    echo "HOST1 = " $HOST1

    HOST="BLA"
    HOST1="BLA1"
}

fn_2(){
    echo "P12 = " $1
    echo "HOST_MOD = " $HOST
    echo "HOST1_MOD = " $HOST1
}

for HOST in "${HOSTS[@]}"
do
    HOST1=$HOST
    fn_1 $HOST
    fn_2 $HOST
done
