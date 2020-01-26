#!/bin/sh

# example usage: colonConfig user ~/.example.conf /etc/example.conf anonymous
# key     = user
# config1 = ~/.example.conf
# config2 = /etc/example.conf
# default = anonymous

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

envVarName="CONFIG_$(printf '%s' "$key" | tr 'a-z-' 'A-Z_')"
# return the value of the corresponding environment variable if it exists
# shellcheck disable=SC2016
eval "$(printf 'if [ ! -z ${%s+x} ]; then printf '"'"'%%s\n'"'"' "${%s}"; exit 0; fi' "$envVarName" "$envVarName")"

# dependencies
module "colonValue" "https://mdl.sh/config/colon/colon-value/colon-value-0.9.3.sh" "cksum-3777497321"
module "colonValueExists" "https://mdl.sh/config/colon/colon-value-exists/colon-value-exists-0.9.0.sh" "cksum-1190398940"

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
