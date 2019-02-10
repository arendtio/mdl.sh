#!/bin/sh
# guarantees: intentional-side-effects

# Examples
# Printing the debug message every time the function is called:
# debug "Executing this section" 0
#
# Print the debug message only when at least one of DEBUG_ALL or DEBUG_MYSEC is set to a number larger or equal to 2
# debug "Executing this section" "MYSEC" 2

## mandatory:
## error message
#msg="$1"
#
## optional:
## debug section
#section="${2:-ALL}"
## debug level when the message should be displayed
#level="${3:-1}"
#
#envDebugLevel="$(printf '%s' "${DEBUG_ALL:-0}")"
#envDebugSectionLevel="$(eval "printf '%s\\n' \"\${DEBUG_$section:-$envDebugLevel}\"")"
#if [ "$envDebugSectionLevel" -ge "$level" ]; then
#	printf '%s: %s\n' "$section" "$msg" >&2
#fi

if [ "$(eval "printf '%s\\n' \"\${DEBUG_${2:-ALL}:-$(printf '%s' "${DEBUG_ALL:-0}")}\"")" -ge "${3:-1}" ]; then
	printf '%s: %s\n' "${2:-ALL}" "$1" >&2
fi

# TODO: for 1.0, consider
#	- switching positions of level and section
#	- using DEBUG_NAMESPACE
