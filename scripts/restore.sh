#!/bin/sh
/workspace/scripts/git.sh

find $GIT_WORK_TREE -not -path '*/.git*' -type f | while read path; do
    rel_file=$(realpath --relative-to="$GIT_WORK_TREE" "$path")
    rsyncrypto -d "$path" "$RESTORE_PATH/$rel_file" "$KEYS_DIR/$rel_file.key" "$SYNC_MAIN" -v
    /workspace/scripts/owner.sh "$path" "$RESTORE_PATH" "$GIT_WORK_TREE"
done;

rm -rf $KEYS_DIR/*