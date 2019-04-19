#!/bin/sh

# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
url="$1"

# dependencies
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"

# The debug module uses this variable
export DEBUG_NAMESPACE="HTTPS_GET"

# check if it is an https url
if [ "$(printf '%s' "$url" | head -c 8 | tr '[:upper:]' '[:lower:]')" != "https://" ]; then
	error "'$url' does not start with 'https://'. Exiting." 65
fi

rc="1"

# find out command- v http client is available and use it
if command -v curl >/dev/null 2>&1; then
	debug "Using curl" 1
	curl -sL "$url"
	rc="$?"
elif command -v wget >/dev/null 2>&1; then
	debug "Using wget" 1
	wget -qO - "$url"
	rc="$?"
elif command -v openssl >/dev/null 2>&1; then
	debug "Using openssl" 1
	host="$(printf '%s\n' "$url" | sed -e 's;^[^/]\{1,\}://;;' -e 's;[/:].*$;;')"
	path="$(printf '%s\n' "$url" | sed -e 's;^[^/]\{1,\}://[^/]\{1,\}/;/;')" # with leading /
	port="$(printf '%s\n' "$url" | sed -e 's;^[^/]\{1,\}://[^/]\{1,\}:\([0-9]\{1,\}\)/.*$;\1;')"
	if [ "$port" = "$url" ]; then
		port="443"
	fi

	# sed to remove the headers from the output
	printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$path" "$host" | openssl s_client -quiet -connect "$host:$port" 2>/dev/null | sed '1,/^\r$/d'
	rc="$?"
elif command -v ftp >/dev/null 2>&1 && [ "$(ftp -h 2>&1 | grep -c http)" -gt 0 ]; then
	# if the cli program 'ftp' exists, we try to find out if it is the correct version (OpenBSD vs. GNU)
	debug "Using ftp" 1
	ftp -o - "$url"
	rc="$?"
else
	error "None of curl, wget and openssl is available. Exiting."
fi

if [ "$rc" -ne 0 ]; then
	debug "Non-zero rc '$rc', replacing it now" 1
	# actually we don't know the exact reason why it failed, but unavailability is the most common/likely
	exit 69
fi
