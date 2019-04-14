#!/bin/sh
# guarantees: intentional-side-effects
# To understand this code please take a look at the README.md

if [ "$#" -gt 0 ] &&  [ "$(eval "printf '%s\\n' \"\${DEBUG_${3:-${DEBUG_NAMESPACE:-ALL}}:-$(printf '%s' "${DEBUG_ALL:-0}")}\"")" -ge "${2:-1}" ]; then
	printf '%s: %s\n' "${3:-${DEBUG_NAMESPACE:-ALL}}" "$1" >&2
fi
