#!/bin/bash
echo "$(date) - Backing up: $SCHED_PATH" >> /var/log/cron.log 2>&1
/workspace/scripts/actions/copy.sh "$SCHED_PATH" "$SCHED_PATH$1"
/workspace/scripts/actions/commit.sh "$SCHED_PATH$1" "[$1] SCHEDULED"