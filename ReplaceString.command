#!/bin/sh

echo "Enter the string you want to replace:"
read old

echo "Enter the new string you want to insert:"
read name

echo "Changing $old to $name..."

# set the directory to the dir in which this script resides
newPath=`echo $0 | awk '{split($0, a, ";"); split(a[1], b, "/"); for(x = 2; x < length(b); x++){printf("/%s", b[x]);} print "";}'`
cd "$newPath"

# run through all directories, change them first
find . -type d -print 2>/dev/null | while read file
do
	# do not allow changing of this script
	if [[ $file == *.command* ]]
	then
		#echo "Ignoring $file"
	  	continue
	fi
	
	# do not allow changing of anything in .git
	if [[ $file == *.git* ]]
	then
		#echo "Ignoring $file"
	  	continue
	fi
	
	# Rename the directory itself
	if [[ $file == *$old* ]]
	then
		newName=`echo $file | sed "s/$old/$name/g"`
		echo "Renaming directory $file to $newName"
		mv "$file" "$newName"
	fi
done


# run through all files...
find . -type f -print0 | xargs -0 file | cut -f1 -d: 2>/dev/null | while read file
do
	newName=`echo $file | sed "s/$old/$name/g"`
	echo "Renaming $file to $newName"
	mv "$file" "$newName"
done