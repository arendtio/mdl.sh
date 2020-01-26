#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 0 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# the purpose of this module is to reference a module that references an outdated version

# referencing the updateable-by-outdated-reference-1.0.0 module
module "updateableByOutdatedReference" "https://mdl.sh/development/module/dependency/updatable/spec/assets/updateable-by-outdated-reference-1.0.0.sh" "cksum-1153090430"
