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
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"

result="0"
output="$(eval "$cmd" 2>&1)" || result="$?" && true
debug "$(printf 'command "%s" output:\n%s\n\n' "$cmd" "$output")" 1 "${DEBUG_NAMESPACE:-ASSERT_RETURN_CODE}"
assertEqual "$name" "$result" "$target"
