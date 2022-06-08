#! /bin/sh
echo "$1 $2"

case $2 in
    "$1/cipher/"*) 
        echo "Cipher $1 $2"
        rsyncrypto "$2" "$GIT_WORK_TREE" "$KEYS_DIR" "$SYNC_CERT" -r -c --delete -v --trim=2;
        /workspace/scripts/owner.sh $2 $GIT_WORK_TREE "/workspace/backup";;
    *) 
        echo "Plain $1 $2"
        rel_path=$(realpath --relative-to="$BACKUP_ROOT" "$2");
        echo "$GIT_WORK_TREE/$rel_path";
        rsync -qcrlpEAogtU $2 $GIT_WORK_TREE --delete-excluded --mkpath "$GIT_WORK_TREE/$rel_path";;
esac