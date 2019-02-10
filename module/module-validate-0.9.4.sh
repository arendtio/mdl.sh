#!/bin/sh

src="$1"
targetHash="$2"

module "moduleChecksum" "https://mdl.sh/module/module-checksum-0.9.2.sh" "cksum-1965395284"

hashFunc="$(printf '%s' "$targetHash" | cut -d '-' -f1)"
srcHash="$(moduleChecksum "$src" "$hashFunc")"
if [ "$srcHash" != "$targetHash" ]; then
	return 1
fi
