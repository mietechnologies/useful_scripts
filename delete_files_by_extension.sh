#!/bin/bash
# This script will recursively move through all subdirectories of the parent it
# is executed in and delete all files that have the file extension provided at
# execution

ROOT="$PWD"
EXTENSION=$1

delete_file() {
    echo "deleting $1"
    rm $1
}

recurse_directory() {
    for i in "$1"/*; do
        if [ -d "$i" ]; then
            recurse_directory "$i"
        elif [ -f "$i" ]; then
            if [[ $i == *.$EXTENSION ]]; then
                delete_file $i
            fi
        fi
    done
}

if [ -z "$EXTENSION" ]; then
    echo "extension required!"
    exit 1
else
    read -n 1 -p "this is a destructive operation; are you sure? [y/n] " input
    if [ "$input" = "n" ]; then
        echo "terminating..."
        exit 0
    elif [ "$input" = "no" ]; then
        echo "terminating..."
        exit 0
    fi
fi

for i in "$ROOT"/*; do
    if [ -d "$i" ]; then
        recurse_directory "$i"
    fi
done