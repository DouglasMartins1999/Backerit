#!/bin/sh
/workspace/scripts/git.sh

tail -n +2 $SCHED_FILE | while IFS=";" read -r path cron
do
    if [ -d $path ]
    then
        rsyncrypto "$path" "$GIT_WORK_TREE" "$KEYS_DIR" "$SYNC_CERT" -r -c --delete -v
        /workspace/scripts/owner.sh $path $GIT_WORK_TREE "/workspace"
    fi
done

rsyncrypto "$MONITOR_PATH" "$GIT_WORK_TREE" "$KEYS_DIR" "$SYNC_CERT" -r -c --delete -v
/workspace/scripts/owner.sh $MONITOR_PATH $GIT_WORK_TREE "/workspace"
/workspace/scripts/commit.sh /workspace "FILE SYNC"