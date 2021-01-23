#!/bin/sh

#implementation="$1"
directory="$2"

num="$(find "$directory" | wc -l)"
if [ "$num" -ne 1 ]; then
	exit 1
fi
