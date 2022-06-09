#!/bin/bash

inotifywait -m --excludei "\.((tmp)|(swp))$" -r $MONITOR_PATH \
    -e create -e moved_to -e close_write -e moved_from -e delete -e attrib |
    while read path action file; do
        rel_file=$(realpath --relative-to="$MONITOR_PATH" "$path")

        if [ -d $path ]
        then
            rel_file=$(realpath --relative-to="$MONITOR_PATH" "$file")
            /workspace/scripts/actions/copy.sh $MONITOR_PATH $path
        fi 

        message="[$rel_file] $action"
        /workspace/scripts/actions/commit.sh "$path" "$message"
    done