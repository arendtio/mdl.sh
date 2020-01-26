#!/bin/sh

# mandatory parameters
key=$1
file=$2

# check if the file exists
if ! [ -f "$file" ]; then
	exit 1
fi

# try to find the key within the file
grep -e "^$key:" "$file" >/dev/null

# use the return value to signal success and failure
exit $?
