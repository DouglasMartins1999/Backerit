#!/bin/bash
echo ""
echo "=== $(date) ==="
echo $1
echo $2

git add .git-preserve-permissions
git add $(realpath --relative-to="$BACKUP_ROOT" "$1")
git commit -m "$2" &> /dev/null
git push origin $(git symbolic-ref --short HEAD) &> /dev/null

echo "Done"