set_cmd_print_exec_fn() {
    CMD="$1"
    echo " -> Executing " "$CMD"
    $CMD
    unset CMD
} 

set_cmd_print_exec_fn $1
