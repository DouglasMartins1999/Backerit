#!/bin/sh
/workspace/scripts/git.sh

monitor_folder=$(printf '%s' "$MONITOR_PATH" | tr "$BACKUP_ROOT" '')
scheds_folder=$(printf '%s' "$SCHED_PATH" | tr "$BACKUP_ROOT" '')

cipher_restore() {
    rsyncrypto -d "$1" "$RESTORE_PATH/$2" "$KEYS_DIR/$2.key" "$SYNC_MAIN" -v
    /workspace/scripts/owner.sh "$1" "$RESTORE_PATH" "$GIT_WORK_TREE"
}

case $path in
        "$GIT_WORK_TREE$monitor_folder/cipher/"*) 
            cipher_restore $path $rel_file
        "$GIT_WORK_TREE$scheds_folder/cipher/"*) 
            cipher_restore $path $rel_file
        *) 
            rel_path=$(printf '%s' "$path" | tr "$GIT_WORK_TREE" '')
            rsync -qcrlpEAogtUN /app/src/test/test2/ /app/repo/ --mkpath /app/repo/test/test2/ 
            rsync -qcrlpEAogtUN $path $RESTORE_PATH/rel_path --delete-excluded --mkpath $RESTORE_PATH/$rel_path;;
    esac

find "$GIT_WORK_TREE$monitor_folder/cipher/" -type f | while read path; do
    rel_file=$(realpath --relative-to="$GIT_WORK_TREE" "$1")
    cipher_restore $path $rel_file
done;

find "$GIT_WORK_TREE$scheds_folder/cipher/" -type f | while read path; do
    rel_file=$(realpath --relative-to="$GIT_WORK_TREE" "$1")
    cipher_restore $path $rel_file
done;

find "$GIT_WORK_TREE" -type d \
    -not -path '*/.git*' \
    -not -path "$GIT_WORK_TREE$monitor_folder/cipher/*" \
    -not -path "$GIT_WORK_TREE$scheds_folder/cipher/*" | while read path; do
    
    rel_path=$(printf '%s' "$path" | tr "$GIT_WORK_TREE" '')
    rsync -qcrlpEAogtUN $path $RESTORE_PATH --mkpath $RESTORE_PATH$rel_path;
done;

rm -rf $KEYS_DIR/*