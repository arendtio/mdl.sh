#!/bin/sh

# check number of arguments
if [ "$#" -ne 3 ]; then
	printf 'Not three arguments\n' >&2
	exit 64
fi

# mandatory parameters
name="$1"
target="$2"
cmd="$3"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
# start module https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh
assertEqual() { (
set -eu
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
) }
# end module https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh
# start module https://mdl.sh/development/debug/debug-1.0.0.sh
debug() {
# guarantees: intentional-side-effects
# To understand this code please take a look at the README.md

if [ "$#" -gt 0 ] &&  [ "$(eval "printf '%s\\n' \"\${DEBUG_${3:-${DEBUG_NAMESPACE:-ALL}}:-$(printf '%s' "${DEBUG_ALL:-0}")}\"")" -ge "${2:-1}" ]; then
	printf '%s: %s\n' "${3:-${DEBUG_NAMESPACE:-ALL}}" "$1" >&2
fi
}
# end module https://mdl.sh/development/debug/debug-1.0.0.sh

result="0"
output="$(eval "$cmd" 2>&1)" || result="$?" && true
debug "$(printf 'command "%s" output:\n%s\n\n' "$cmd" "$output")" 1 "${DEBUG_NAMESPACE:-ASSERT_RETURN_CODE}"
assertEqual "$name" "$result" "$target"
