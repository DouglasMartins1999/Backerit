#!/bin/bash
/workspace/scripts/setup/repo.sh

monitor_folder=$(realpath --relative-to="$BACKUP_ROOT" "$MONITOR_PATH")
scheds_folder=$(realpath --relative-to="$BACKUP_ROOT" "$SCHED_PATH")

find "$GIT_WORK_TREE/$monitor_folder/cipher/" "$GIT_WORK_TREE/$scheds_folder/cipher/" -type f | while read path; do
    rel_file=$(realpath --relative-to="$GIT_WORK_TREE" "$path")
    rsyncrypto -d "$path" "$RESTORE_PATH/$rel_file" "$KEYS_DIR/$rel_file.key" "$SYNC_MAIN" -v
    /workspace/scripts/actions/owner.sh "$path" "$RESTORE_PATH" "$GIT_WORK_TREE"
done;

rsync -qcrlpEAogtU "$GIT_WORK_TREE/$scheds_folder/plain/" --mkpath "$RESTORE_PATH/$scheds_folder/plain/"
rsync -qcrlpEAogtU "$GIT_WORK_TREE/$monitor_folder/plain/" --mkpath "$RESTORE_PATH/$monitor_folder/plain/"

rm -rf $KEYS_DIR/*