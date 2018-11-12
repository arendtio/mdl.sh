#!/bin/sh

identifier="$1"

if [ "$(printf '%s' "$identifier" | head -c 5 | tr '[:upper:]' '[:lower:]')" = "https" ]; then
	## it seems to be an URL
	location="$identifier"
elif [ -f "$identifier" ]; then
	## it seems to be a path
	location="$identifier"
else
	## trying to transform the identifier to an URL
	if [ "${identifier#*/}" != "$identifier" ]; then
		# the identifier contains a slash
		location="https://mdl.sh/$identifier"
	else
		# no slash present within the identifier
		packageName="$(echo "$identifier" | sed -e 's;^\([^/]*\)-[^/-]*$;\1;' -e 's/-static$//' -e 's/-test$//')"
		location="https://mdl.sh/$packageName/$identifier"
	fi
	location="$(echo "$location" | sed 's;\([^:]\)//;\1/;g')"
fi

echo "$location"
