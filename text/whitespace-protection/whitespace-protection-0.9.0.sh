#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
action="$1"

if [ "$action" = "add" ]; then
	# add the strings before and after the input
	printf '%s' "AAA"
	cat -
	printf '%s' "ZZZ"
elif [ "$action" = "remove" ]; then
	# remove the protection string before and after the content
	input="$(cat -)"
	input="${input#AAA}"
	input="${input%ZZZ}"
	printf '%s' "$input"
else
	printf 'Invalid argument (neither "add" nor "remove")\n' >&2
	exit 64
fi
