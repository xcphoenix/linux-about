#!/bin/bash

shell_path=
log_dir=
log_save_days=3

readonly ERR_EXEX=3
readonly ERR_USAG=2

function err() {
    echo "$1"
    exit $ERR_EXEX
}

function help() {
    echo "usage -e SHELL_PATH [-d LOG_DIR] [-s LOG_SAVE_DAYS]"
    echo " -d default same as SELL_PATH/logs"
    echo " -s default 3 days"
}

function getOptionVal() {
    if [ $# -lt 2 ] || [ -z "$2" ]; then
        echo "miss option[$1] value"
        help
        exit $ERR_USAG
    fi
    echo "$2"
}

if [[ $# -lt 1 ]]; then
    help
    exit 1
fi

while (($# > 0)); do
    case $1 in
    -e)
        shell_path=$(getOptionVal "$@")
        shift 2
        if [ ! -f "$shell_path" ]; then
            err "can't find shell"
        elif [ ! -x "$shell_path" ]; then
            err "can't exec shell"
        fi
        ;;
    -d)
        log_dir=$(getOptionVal "$@")
        shift 2
        if [ ! -d "$log_dir" ]; then
            if mkdir -p "$log_dir"; then
                err "create log dir failed"
            fi
        fi
        ;;
    -s)
        log_save_days=$(($(getOptionVal "$@") + 0))
        shift 2
        ;;
    -h)
        help
        shift 1
        exit 0
        ;;
    *) 
        shift 1
    esac
done

if [ -z "$shell_path" ]; then
    help
    exit $ERR_USAG
fi

if [ -z "$log_dir" ]; then
    log_dir=${shell_path%/*}/logs
    if [ ! -d "$log_dir" ]; then
        if mkdir -p "$log_dir"; then
            err "create log dir failed"
        fi
    fi
fi

exec_date=$(date -I)
$shell_path >>"$log_dir"/"$exec_date".log 2>&1 && ln -fs "$log_dir"/"$exec_date".log "$log_dir"/run.log

if [ $log_save_days -ne 0 ]; then
    cd "$log_dir" && ls -t | grep -E '[0-9]+-[0-9]+-[0-9]+.log' | sed -n "$log_save_days,\$p" | xargs -r rm -rf
fi
