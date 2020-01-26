#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 0 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# the purpose of this module is to reference an outdated module

# referencing the outdated updateable-by-version-1.0.0.sh
module "updateableByVersion" "https://mdl.sh/development/module/dependency/updatable/spec/assets/updateable-by-version-1.0.0.sh" "cksum-2183704118"
