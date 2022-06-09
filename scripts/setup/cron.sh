#!/bin/bash

rm -f $CRON_FILE
touch $CRON_FILE
touch /var/log/cron.log

echo ""
echo "Scheduling Backup to Following Folders:"
echo ""

tail -n +2 $SCHED_FILE | while IFS=";" read -r path cron; do
  echo "Folder: $path"
  echo "Cron Exp: $cron"
  echo ""

  echo "$cron /workspace/scripts/actions/cron.sh $path" >> $CRON_FILE
done

chmod 0644 $CRON_FILE
crontab $CRON_FILE
cron start