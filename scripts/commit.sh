#!/bin/bash
echo "Commiting With Message: $2"
git add .git-preserve-permissions
git add $(realpath --relative-to="$BACKUP_ROOT" "$1")
git commit -m "$2"
git push origin $GIT_BRANCH