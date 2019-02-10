#!/bin/sh

if [ "$#" -lt 2 ]; then
	printf 'This function requires at least two arguments.\n' >&2
	exit 1
fi

# parameters
# the first parameter must be the key, the last the default value
# in between can be an arbitraty number of config files
# if a key will be found in a config files the later ones will be skipped
key="$1"
shift 1

# example usage: colonConfig user ~/.example.conf /etc/example.conf anonymous
# key     = user
# config1 = ~/.example.conf
# config2 = /etc/example.conf
# default = anonymous

# dependencies
module "colonValue" "https://mdl.sh/colon-config/colon-value-0.9.2.sh" "cksum-2319627931"
module "colonValueExists" "https://mdl.sh/colon-config/colon-value-exists-0.9.0.sh" "cksum-316889988"

# try to find the key in the list of config files
while [ "$#" -gt 1 ]; do
	configFile="$1"
	shift 1

	if [ -f "$configFile" ] && colonValueExists "$key" "$configFile"; then
		colonValue "$key" "$configFile"
		exit 0
	fi
done

# no key found in config files, using default value
defaultValue="$1"
printf '%s\n' "$defaultValue"
