#!/bin/sh

# mandatory parameters
key=$1
file=$2

# check if the file exists
if ! [ -f "$file" ]; then
	exit 1
fi

# extract value for the specific key
grep -e "^$key:" "$file" \
	| cut -d':' -f2- \
	| sed 's/\(^[[:space:]]\+\|[[:space:]]\+$\)//g'
