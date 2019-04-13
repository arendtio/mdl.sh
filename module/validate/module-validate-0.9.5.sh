#!/bin/sh

src="$1"
targetHash="$2"

module "moduleChecksum" "https://mdl.sh/module/checksum/module-checksum-0.9.3.sh" "cksum-1965395284"

hashFunc="$(printf '%s' "$targetHash" | cut -d '-' -f1)"
srcHash="$(moduleChecksum "$src" "$hashFunc")"
if [ "$srcHash" != "$targetHash" ]; then
	return 1
fi
