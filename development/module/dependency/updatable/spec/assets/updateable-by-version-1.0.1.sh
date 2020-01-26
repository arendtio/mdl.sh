#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 0 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# this is the newest version of the outdated 1.0.0 module
