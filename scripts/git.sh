#!/bin/sh
if [ $(git remote | wc -l) -eq 0 ] 
then
    touch -a $GIT_SSH_KEY
    chmod 600 $GIT_SSH_KEY
    echo "IdentityFile $GIT_SSH_KEY" >> /etc/ssh/ssh_config 
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
    echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /etc/ssh/ssh_config

    git config --global credential.helper store
    git config --global init.defaultBranch "$GIT_BRANCH"
    git config --global user.email "$GIT_EMAIL"
    git config --global user.name "$GIT_USERNAME"
    
    git branch -m $GIT_BRANCH
    git remote add origin $GIT_REMOTE_URL
    git pull --set-upstream origin $GIT_BRANCH
fi