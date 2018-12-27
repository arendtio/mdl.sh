#!/bin/sh
set -eEuo pipefail

if [ "$#" != "2" ]; then
	echo "2 arguments are required"
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "The input file does not exist. Aborting."
	exit 1
fi

if [ -e "$2" ]; then
	echo "The result file exists already. Aborting."
	exit 1
fi

eval "$(curl -fsL "https://mdl.sh/latest")"
module "moduleCompiler" "https://mdl.sh/module/module-compiler-0.9.5.sh" "cksum-4290536567"

moduleCompiler "$(cat "$1")" "$(dirname "$1")" > "$2"
chmod +x "$2"
