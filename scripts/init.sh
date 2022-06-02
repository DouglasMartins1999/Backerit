#!/bin/sh

# Git Repo Setup
/workspace/scripts/git.sh

if [ ! "$SYNC_ON_INIT" = "" ]
then
    /workspace/scripts/sync.sh
fi

# Cron Tab Setup
rm -f $CRON_FILE
touch $CRON_FILE
touch /var/log/cron.log

echo ""
echo "Scheduling Backup to Following Folders:"
echo ""

tail -n +2 $SCHED_FILE | while IFS=";" read -r path cron
do
  echo "Folder: $path"
  echo "Cron Exp: $cron"
  echo ""

  echo "$cron /workspace/scripts/cron.sh $path" >> $CRON_FILE
done

chmod 0644 $CRON_FILE
crontab $CRON_FILE
cron start

# Monitor Setup
inotifywait -m --excludei "\.((tmp)|(swp))$" -r $MONITOR_PATH -e create -e moved_to -e close_write -e moved_from -e delete -e attrib |
    while read path action file; do
        rel_file=$(realpath --relative-to="$MONITOR_PATH" "$path")

        if [ -d $path ]
        then
            rel_file=$(realpath --relative-to="$MONITOR_PATH" "$file")
            rsyncrypto "$path" "$GIT_WORK_TREE" "$KEYS_DIR" "$SYNC_CERT" -r -c --delete -v
            /workspace/scripts/owner.sh $path $GIT_WORK_TREE "/workspace"
        fi 

        message="[$rel_file] $action"
        ./scripts/commit.sh "$path" "$message"
    done