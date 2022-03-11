#!/bin/zsh

# This shell script is intended to take care of cleaning out old Xcode junk and
# will evolve as needed when Xcode adds more junk to clean...

echo "What is the minimum iOS version you would like to retain support for?"
echo "(this should be the minimum iOS version on any physical device you have)"
read minimum_supported_version

# Quit Xcode
osascript -e 'quit app "Xcode"'

# Delete all derived data
cd ~/Library/Developer/Xcode/DerivedData
if [ $( ls | wc -l ) -gt 1 ]; then
    # If no contents, no reason to delete
    rm -rf ~/Library/Developer/Xcode/DerivedData/*
fi

# Delete any unused caches
xcrun simctl delete unavailable

# Delete any unused preview data
xcrun simctl --set previews delete unavailable

# Remove all directories under ~/Library/Developer/Xcode/iOS DeviceSupport
# besides the 2 latest versions
cd ~/Library/Developer/Xcode/iOS\ DeviceSupport
for FILE in *; do
    # Like: 15.3 (19D49) arm64e
    version=$( echo "$FILE" | cut -c1-4 )
    if [ 1 -eq "$( echo "$version < $minimum_supported_version" | bc)" ]; then
        echo "removing $FILE because $version is older than $minimum_supported_version"
        rm -rf $FILE
    fi
done

# Remove all data from ~/Library/Developer/CoreSimulator if it's been more than
# 1 month since it was last used
cd ~/Library/Developer/CoreSimulator/Devices
for FILE in *; do
    file_timestamp=$(date -r $FILE '+%s')
    one_month_ago=$(( $( date '+%s' )-60*60*24*30 ))

    if [ $file_timestamp -lt $one_month_ago ]; then
        echo "removing $FILE because it hasn't been used in over a month"
        rm -rf $FILE
    fi
done

# Clean out all device backups besides the latest
cd ~/Library/Application\ Support/MobileSync/Backup
newest_backup=""
newest_backup_date=0
for FILE in *; do
    if [ -d $FILE ]; then
        file_timestamp=$( date -r $FILE '+%s' )

        if [ $file_timestamp > $newest_backup_date ]; then
            newest_backup=$FILE
            newest_backup_date=$file_timestamp
        fi
    fi
done

echo "should keep $newest_backup because it's the latest backup"

# Once we've determined what backup to keep, we should iterate through
# backups again and delete everything but that one
for FILE in *; do
    if [ -d $FILE ]; then
        if [ $FILE != $newest_backup ]; then
            echo "removing $FILE because it's an old backup"
            rm -rf $FILE
        fi
    fi
done

# Any cleanup needed
rm -rf $newest_backup_date
