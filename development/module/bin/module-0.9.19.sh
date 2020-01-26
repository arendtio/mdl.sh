#!/bin/sh
# This script is supposed to be called as "module init" and printf the content
# of module.sh to stdout to be consumed by eval Furthermode, it should be use
# as the static version only!

if [ "$#" -ne 1 ] || [ "$1" != "init" ]; then
	printf 'The module adapter was called without the "init" argument. Someone probably forgot to call "module init" before using "module".\n' >&2
	exit 1
fi

# TODO: add exit condition which the compiler removes

# print the content of module.sh to stdout
cat << 'moduleAdapterEOF'
module "module" "https://mdl.sh/development/module/core/module-core-0.9.19.sh" "cksum-1616189340"
moduleAdapterEOF
