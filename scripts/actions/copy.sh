#!/bin/bash
case $2 in
    "$1/cipher/"*) 
        rsyncrypto "$2" "$GIT_WORK_TREE" "$KEYS_DIR" "$SYNC_CERT" -r -c --delete -v --trim=2;
        /workspace/scripts/actions/owner.sh $2 $GIT_WORK_TREE "/workspace/backup";;
    *) 
        rel_path=$(realpath --relative-to="$BACKUP_ROOT" "$2");
        rsync -qcrlpEAogtU $2 --delete-excluded --mkpath "$GIT_WORK_TREE/$rel_path";;
esac