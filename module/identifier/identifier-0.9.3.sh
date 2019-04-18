#!/bin/sh

if [ "$#" -ne 1 ]; then
	printf 'Expected one argument, but found %s.' "$#"
	exit 1
fi

identifier="$1"

if [ "$(printf '%s' "$identifier" | head -c 5 | tr '[:upper:]' '[:lower:]')" = "https" ]; then
	## it seems to be an URL
	location="$identifier"
else
	## trying to transform the identifier to an URL
	if [ "${identifier#*/}" != "$identifier" ]; then
		# the identifier contains a slash
		location="https://mdl.sh/$identifier"
	else
		# no slash present within the identifier
		packageName="$(printf '%s' "$identifier" | sed -e 's;^\([^/]*\)-[^/-]*$;\1;' -e 's/-static$//' -e 's/-test$//')"
		location="https://mdl.sh/$packageName/$identifier"
	fi
	location="$(printf '%s' "$location" | sed 's;\([^:]\)//;\1/;g')"
fi

printf '%s\n' "$location"
