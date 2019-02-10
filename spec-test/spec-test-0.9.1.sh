#!/bin/sh

# mandatory parameters
spec="$1"
implementation="$2"

# dependencies
module "error" "https://mdl.sh/error/error-1.0.2.sh" "cksum-2718151387"

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
