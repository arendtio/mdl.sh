#!/bin/sh
set -eu

if [ "$#" != "2" ]; then
	printf '2 arguments are required\n'
	exit 1
fi

if [ ! -f "$1" ]; then
	printf 'The input file does not exist. Aborting.\n'
	exit 1
fi

if [ -e "$2" ]; then
	printf 'The result file exists already. Aborting.\n'
	exit 1
fi

eval "$(curl -fsL "https://mdl.sh/latest")"
module "moduleCompiler" "https://mdl.sh/module/compiler/module-compiler-0.9.20.sh" "cksum-3329462786"

moduleCompiler "$(cat "$1")" "$(dirname "$1")" > "$2"
chmod +x "$2"
