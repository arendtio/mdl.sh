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
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.5.sh" "cksum-566303087"
module "debug" "https://mdl.sh/debug/debug-0.9.2.sh" "cksum-2374238394"

result="0"
output="$(eval "$cmd" 2>&1)" || result="$?" && true
debug "$(printf 'command "%s" output:\n%s\n\n' "$cmd" "$output")" DEBUG_ASSERT_RETURN_CODE 1
assertEqual "$name" "$result" "$target"
