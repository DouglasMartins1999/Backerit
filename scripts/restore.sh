#!/bin/bash
/workspace/scripts/setup/repo.sh

monitor_folder=$(realpath --relative-to="$BACKUP_ROOT" "$MONITOR_PATH")
scheds_folder=$(realpath --relative-to="$BACKUP_ROOT" "$SCHED_PATH")

cipher_restore() {
    rel_file=$(realpath --relative-to="$GIT_WORK_TREE" "$1")
    rsyncrypto -d "$1" "$RESTORE_PATH/$2" "$KEYS_DIR/$2.key" "$SYNC_MAIN" -v
    /workspace/scripts/actions/owner.sh "$1" "$RESTORE_PATH" "$GIT_WORK_TREE"
}

find "$GIT_WORK_TREE$monitor_folder/cipher/" -type f | while read path; do
    cipher_restore $path $rel_file
done;

find "$GIT_WORK_TREE$scheds_folder/cipher/" -type f | while read path; do
    cipher_restore $path $rel_file
done;

find "$GIT_WORK_TREE" -type d \
    -not -path '*/.git*' \
    -not -path "$GIT_WORK_TREE$monitor_folder/cipher/*" \
    -not -path "$GIT_WORK_TREE$scheds_folder/cipher/*" | while read path; do
    
    rel_path=$(realpath --relative-to="$GIT_WORK_TREE" "$path")
    rsync -qcrlpEAogtU "$path" "$RESTORE_PATH" --mkpath "$RESTORE_PATH/$rel_path";
done;

rm -rf $KEYS_DIR/*