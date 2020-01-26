#!/bin/sh

# mandatory parameters
identifier="$1"
actualResult="$2"
validResult="$3"

# optional parameters
failCode="${4:-1}"

# dependencies
# start module https://mdl.sh/development/error/error-1.0.4.sh
error() {
# guarantees: intentional-side-effects

# mandatory:
# error message
#msg="$1"

# optional:
# exit code
#code="${2:-1}"

printf '%s\n' "$1" >&2
exit "${2:-1}"
}
# end module https://mdl.sh/development/error/error-1.0.4.sh
# start module https://mdl.sh/development/debug/debug-1.0.0.sh
debug() {
# guarantees: intentional-side-effects
# To understand this code please take a look at the README.md

if [ "$#" -gt 0 ] &&  [ "$(eval "printf '%s\\n' \"\${DEBUG_${3:-${DEBUG_NAMESPACE:-ALL}}:-$(printf '%s' "${DEBUG_ALL:-0}")}\"")" -ge "${2:-1}" ]; then
	printf '%s: %s\n' "${3:-${DEBUG_NAMESPACE:-ALL}}" "$1" >&2
fi
}
# end module https://mdl.sh/development/debug/debug-1.0.0.sh

debug "ASSERT: '$actualResult' = '$validResult'" 2 "${DEBUG_NAMESPACE:-ASSERT}"
if [ "$actualResult" != "$validResult" ]; then
	error "$(printf 'FAIL: "%s" test failed\nActual result: "%s"\nExpected result: "%s"\n' "$identifier" "$actualResult" "$validResult")" "$failCode"
fi
