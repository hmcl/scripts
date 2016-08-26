
MAX_CLUSTER_ID=3

unzip_nimbus_locally() {
    FILE_NAME="$1"
    ZIP_PATH="/$DIR/$STORM_I/$FILE_NAME.zip"
    unzip "$ZIP_PATH" -d "$1";
    mv "$DIR/grid/3/hmcl/$STORM_I/apache-storm-0.10.0-SNAPSHOT/logs/$FILE_NAME/nimbus.log" "$DIR/$STORM_I";
    mv "$DIR/grid/3/hmcl/$STORM_I/apache-storm-0.10.0-SNAPSHOT/logs/$FILE_NAME/nimbus.log.1" "$DIR/$STORM_I";
#    rm -rf $DIR/grid/;
}




for ((i=0; i<=MAX_CLUSTER_ID; i++));
do
    STORM_I="storm$i"
    DIR="/Users/hlouro/Hortonworks/Tasks/EAR/EAR-4185/Reproduce/Logs/$1"

    unzip_nimbus_locally "$1"
#   f echo $1
#    echo $DIR
#    echo $DIR"/$1.zip"
done
