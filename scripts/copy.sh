#! /bin/sh
case $path in
    "$1/cipher/"*) 
        rsyncrypto "$2" "$GIT_WORK_TREE" "$KEYS_DIR" "$SYNC_CERT" -r -c --delete -v;
        /workspace/scripts/owner.sh $2 $GIT_WORK_TREE "/workspace";;
    *) 
        rel_path=$(printf '%s' "$2" | tr "$BACKUP_ROOT" './');
        rsync -qcrlpEAogtUN $2 $GIT_WORK_TREE --delete-excluded --mkpath $GIT_WORK_TREE/$rel_path;;
esac