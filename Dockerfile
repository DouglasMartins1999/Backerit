FROM ubuntu:22.04

ENV GIT_BRANCH=main \
    GIT_DIR=/workspace/config/repo/.git \
    GIT_WORK_TREE=/workspace/config/repo \
    GIT_SSH_KEY=/workspace/config/keys/ssh.key \
    SYNC_MAIN=/workspace/config/keys/backup.key \
    SYNC_CERT=/workspace/config/keys/backup.crt \
    CRON_FILE=/workspace/config/.cron \
    KEYS_DIR=/workspace/config/.keys \
    SCHED_PATH=/workspace/backup/scheduleds \
    MONITOR_PATH=/workspace/backup/monitoring \
    RESTORE_PATH=/workspace/restore

COPY ./scripts/ /tmp/

RUN apt update && \ 
    apt install -y git inotify-tools rsyncrypto cron && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /workspace /workspace/scripts && \
    mkdir /workspace/config /workspace/backup /workspace/restore && \
    mkdir /workspace/config/repo /workspace/backup/monitoring /workspace/backup/scheduleds && \
    cd /workspace/config/repo && git init && \
    printenv | grep -v "no_proxy" >> /etc/environment && \
    cd /tmp && tar -xf preserve.tar && \
    mv /tmp/preserve/hooks/* /workspace/config/repo/.git/hooks && \
    mv /tmp/preserve/git-preserve-permissions /bin && \
    mv /tmp/* /workspace/scripts  && \
    ln -s /workspace/scripts/restore.sh /usr/bin/back-restore && \
    ln -s /workspace/scripts/sync.sh /usr/bin/back-sync

ENTRYPOINT ["/workspace/scripts/init.sh"]
