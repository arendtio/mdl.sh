#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 0 ]; then
	printf 'Invalid number of arguments. Please provide the input via stdin.\n' >&2
	exit 64
fi

# mandatory parameters
# - reading src from stdin

cat - \
	| grep -i "^[[:space:]]*module[[:space:]][^\$]*$" \
	| sed \
		-e "s;^[[:space:]]*module[[:space:]]\{1,\}[\"']\{,1\}[[:alnum:]]\{1,\}[\"']\{,1\}[[:space:]]\{1,\}\(\"\([^\"]\{1,\}\)\"\|'\([^']\{1,\}\)'\|\([^[:space:]]\{1,\}\)\).*$;\2\3\4;"

#		-e 's;^https://[-a-zA-Z0-9\.:]\{1,\}/;;'

