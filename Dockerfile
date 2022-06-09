FROM ubuntu:22.04

ENV GIT_DIR=/workspace/config/repo/.git \
    GIT_WORK_TREE=/workspace/config/repo \
    GIT_SSH_KEY=/workspace/config/defs/ssh.key \
    SYNC_MAIN=/workspace/config/defs/backup.key \
    SYNC_CERT=/workspace/config/defs/backup.crt \
    NTFY_FILE=/workspace/config/defs/notify.txt \
    CRON_FILE=/workspace/config/.cron \
    KEYS_DIR=/workspace/config/.keys \
    BACKUP_ROOT=/workspace/backup \
    SCHED_PATH=/workspace/backup/scheduleds \
    MONITOR_PATH=/workspace/backup/monitoring \
    RESTORE_PATH=/workspace/restore

RUN apt update && \ 
    apt install -y git inotify-tools rsync rsyncrypto cron && \
    rm -rf /var/lib/apt/lists/*

COPY ./scripts/ /tmp/

RUN mkdir /workspace /workspace/scripts && \
    mkdir /workspace/config /workspace/backup /workspace/restore && \
    mkdir /workspace/config/repo /workspace/backup/monitoring /workspace/backup/scheduleds && \
    cd /workspace/config/repo && git init && \
    printenv | grep -v "no_proxy" >> /etc/environment && \
    cd /tmp && tar -xf setup/.own.tar && \
    mv /tmp/preserve/hooks/* /workspace/config/repo/.git/hooks && \
    mv /tmp/preserve/git-preserve-permissions /bin && \
    mv /tmp/* /workspace/scripts  && \
    ln -s /workspace/scripts/restore.sh /usr/bin/back-restore && \
    ln -s /workspace/scripts/sync.sh /usr/bin/back-sync

ENTRYPOINT ["/workspace/scripts/init.sh"]
