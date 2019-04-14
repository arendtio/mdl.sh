#!/bin/sh

# mandatory parameters
spec="$1"
implementation="$2"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"

# prepare a directory
directory="$(mktemp -d)"
ret="$?"
if [ "$directory" = "" ] || [ ! -d "$directory" ] || [ "$ret" -ne 0 ]; then
	error "TEST PREPARTION: mktemp failed" 2
fi

cleanTestSetup() {
	if [ -d "$directory" ]; then
		rm -r "$directory"
	fi
}
trap cleanTestSetup EXIT

# load spec
module "specFunc" "$spec"

# execute spec with a given implementation
specFunc "$implementation" "$directory"
ret="$?"

trap - EXIT
cleanTestSetup

# set return value to test result
exit $ret
