#!/bin/sh

# check number of arguments
if [ "$#" -ne 2 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
spec="$1"
implementation="$2"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "identifier" "https://mdl.sh/development/module/identifier/identifier-0.9.6.sh" "cksum-1159040086"

# convert convinient short identifiers to full URLs
spec="$(identifier "$spec")"
implementation="$(identifier "$implementation")"

# prepare a directory
directory="$(mktemp -d)"
ret="$?"
if [ "$directory" = "" ] || [ ! -d "$directory" ] || [ "$ret" -ne 0 ]; then
	printf 'TEST PREPARTION: mktemp failed\n'
	exit 2
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
