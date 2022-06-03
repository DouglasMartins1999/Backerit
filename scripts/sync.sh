#!/bin/sh
/workspace/scripts/git.sh

tail -n +2 $SCHED_FILE | while IFS=";" read -r path cron
do
    if [ -d $path ]
    then
        /workspace/scripts/copy.sh $SCHED_PATH $path
    fi
done

/workspace/scripts/copy.sh "$MONITOR_PATH" "$MONITOR_PATH/cipher/"
/workspace/scripts/copy.sh "$MONITOR_PATH" "$MONITOR_PATH/plain/"
/workspace/scripts/commit.sh /workspace "FILE SYNC"