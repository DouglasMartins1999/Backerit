#!/bin/bash
if [ $(git remote | wc -l) -eq 0 ]; then
    touch -a $GIT_SSH_KEY
    chmod 600 $GIT_SSH_KEY
    echo "IdentityFile $GIT_SSH_KEY" >> /etc/ssh/ssh_config 
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
    echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /etc/ssh/ssh_config

    git config --global credential.helper store
    git config --global user.email "$GIT_EMAIL"
    git config --global user.name "$GIT_USERNAME"
    
    git remote add origin $GIT_REMOTE_URL
    git pull --set-upstream origin $(git symbolic-ref --short HEAD)
    
    /workspace/scripts/sync.sh
fi