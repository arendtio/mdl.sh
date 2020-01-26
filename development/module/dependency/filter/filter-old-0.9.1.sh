#!/bin/sh
set -eu

# Gets a list of modules and removes all But the latest versions of those modules and specs

# check number of arguments
if [ "$#" -ne 0 ]; then
	printf 'Invalid number of arguments. This module reads from stdin.\n' >&2
	exit 64
fi

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "findVersion" "https://mdl.sh/network/services/mdl/find-version/find-version-0.9.9.sh" "cksum-489523316"

# mandatory parameters
# - stdin

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_FILTER_OLD"

debug "Going to read from stdin" 2

while IFS="" read -r modulePath; do
	debug "Processing $modulePath" 1
	if [ "$modulePath" != "${modulePath%.spec.sh}" ]; then
		# Specs don't have versions, so they are always the latest
		printf '%s\n' "$modulePath"
	elif [ "$(findVersion latestSameMajor "/${modulePath#mdl.sh/}" | sed 's;^/;;')" = "${modulePath#mdl.sh/}" ]; then
		# TODO: this is mdl.sh specific, needs to be fixed
		# this module is the latest version (latestSameMajor)
		printf '%s\n' "$modulePath"
	else
		# this file is not the newest version for this major version and no spec
		# so we don't need to check if it is updatable as there is a newer version already
		# let's skip it
		debug "Skipping $modulePath" 2
	fi
done
