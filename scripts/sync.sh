#!/bin/bash
if [ ! "$SYNC_ON_INIT" = "" ]
then
    tail -n +2 $SCHED_FILE | while IFS=";" read -r path cron; do
        if [ -d $path ]; then
            /workspace/scripts/actions/copy.sh "$SCHED_PATH" "$path"
        fi
    done

    /workspace/scripts/actions/copy.sh "$MONITOR_PATH" "$MONITOR_PATH/cipher/"
    /workspace/scripts/actions/copy.sh "$MONITOR_PATH" "$MONITOR_PATH/plain/"
    /workspace/scripts/actions/commit.sh "$BACKUP_ROOT" "FILE SYNC"
fi