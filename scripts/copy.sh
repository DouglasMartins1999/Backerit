#! /bin/sh
echo "$1 $2"

case $path in
    "$1/cipher/"*) 
        rsyncrypto "$2" "$GIT_WORK_TREE" "$KEYS_DIR" "$SYNC_CERT" -r -c --delete -v;
        /workspace/scripts/owner.sh $2 $GIT_WORK_TREE "/workspace";;
    *) 
        rel_path=$(printf '%s' "$2" | tr "$BACKUP_ROOT" './');
        echo "$GIT_WORK_TREE/$rel_path";
        rsync -qcrlpEAogtU $2 $GIT_WORK_TREE --delete-excluded --mkpath $GIT_WORK_TREE/$rel_path;;
esac