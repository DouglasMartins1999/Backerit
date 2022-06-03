#! /bin/sh
echo "$(date) - Backing up: $SCHED_PATH" >> /var/log/cron.log 2>&1

/workspace/scripts/copy.sh "$SCHED_PATH" "$SCHED_PATH$1"
/workspace/scripts/commit.sh "$SCHED_PATH$1" "[$1] SCHEDULED"