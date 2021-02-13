#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
path="$1"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "mdlList" "https://mdl.sh/network/services/mdl/list/mdl-list-0.9.14.sh" "cksum-1439844879"

findSpecs() { (
	debug "findSpecPairs for path '$path'" 1
	# find would be faster, but requires a local repo
	# find -name "*.spec.sh" -o -name "assets" -prune -false
	mdlList "dirs" "$1" | while IFS="" read -r p || [ -n "$p" ]; do
		# if the directory is called spec, do not continue to descend/recursion
		if [ "$p" != "${p%/spec}" ]; then
			debug "found spec dir '$p'" 2
			mdlList "files" "$p" | while IFS="" read -r spec || [ -n "$spec" ]; do
				if [ "$spec" != "${spec%.spec.sh}" ]; then
					debug "found a spec: $spec" 3
					printf 'https://mdl.sh%s\n' "$spec"
				else
					debug "Skipping '$spec', because it does not look like a spec" 3
				fi
			done
		else
			# recursion
			findSpecs "$p"
		fi
	done
) }

findSpecs "$path"
