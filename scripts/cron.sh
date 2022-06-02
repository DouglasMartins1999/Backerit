#! /bin/sh
echo "$(date) - Backing up: $SCHED_PATH" >> /var/log/cron.log 2>&1
rsyncrypto "$SCHED_PATH$1" "$GIT_WORK_TREE" "$KEYS_DIR" "$SYNC_CERT" -r -c --delete -v
/workspace/scripts/owner.sh $SCHED_PATH$1 $GIT_WORK_TREE "/workspace"
/workspace/scripts/commit.sh "$SCHED_PATH$1" "[$1] SCHEDULED"


#############################################
# CRON N ESTÁ SALVANDO AS PERMISSÕES CORRETAS