#!/usr/bin/env bash

NUM_SAMPLES=900
SECS=2
TO_FILE="/tmp/hmcl/tds/nimbus_400_tps_td_"
PID=21039

date_fn(){
    date "+%H:%M:%S"
}

for ((i=0; i<NUM_SAMPLES; i++)); do
    echo "Saving thread dump to $TO_FILE$i"_"`date_fn`.txt"
    jstack -l $PID >> "$TO_FILE$i"_"`date_fn`.txt"
    sleep $SECS
done