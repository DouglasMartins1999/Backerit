#!/bin/bash

find $1 | while read path; do
    dest=$(realpath --relative-to="$3" "$path")
    chmod --reference=$path $2/$dest --quiet
    chown --reference=$path $2/$dest --quiet
    chgrp --reference=$path $2/$dest --quiet
done;