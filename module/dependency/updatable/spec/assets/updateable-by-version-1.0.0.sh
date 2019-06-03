#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 0 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# this is an outdated module, which doesn't do anything
