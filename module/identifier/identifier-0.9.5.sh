#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
identifier="$1"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"

validationRegex=".*[a-zA-Z][-_a-zA-Z0-9]*-[0-9]\{1,\}\.[-_a-zA-Z0-9\.]*\.sh"

if ! expr "$identifier" : "$validationRegex" >/dev/null ; then
	error "Invalid identifier '$identifier'" 65
fi

if [ "$(printf '%s' "$identifier" | head -c 8 | tr '[:upper:]' '[:lower:]')" = "https://" ]; then
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
