#!/bin/bash

# This script will recursively move through the subdirectories of the parent it
# is executed in prepending each file with the name of the directory.

# Install coreutils in case it isn't installed
brew install coreutils

ROOT="$PWD"

rename_file() {
    local NEW_FILE=""
    NEW_FILE+="$(dirname "$1")/"
    NEW_FILE+="$(prefix "$1")"
    NEW_FILE+="$(basename $1)"

    echo "renaming $(basename $1) to $(prefix "$1")$(basename $1)"
    mv -n "$1" "$NEW_FILE"
}

prefix() {
    local FILE_PREFIX=""

    DIR="$(dirname "$1")"
    DIR_COMPONENTS=${DIR#"$ROOT/"}

    if [[ $DIR_COMPONENTS == *"/"* ]]; then
        IFS=/ read -ra ARRAY <<< "$DIR_COMPONENTS"
        for element in "${ARRAY[@]}"; do
            FILE_PREFIX+="$element"
            FILE_PREFIX+="_"
        done
    else
        FILE_PREFIX=$DIR_COMPONENTS
        FILE_PREFIX+="_"
    fi

    echo $FILE_PREFIX
}

recurse_directory() {
    for i in "$1"/*; do
        if [ -d "$i" ]; then
            recurse_directory "$i"
        elif [ -f "$i" ]; then
            rename_file $i
        fi
    done
}

for i in "$ROOT"/*; do
    if [ -d "$i" ]; then
        recurse_directory "$i"
    fi
done
