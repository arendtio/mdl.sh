#!/bin/sh

src="$1"
checksum="$2"

hashFunc="$(echo "$checksum" | cut -d '-' -f1)"
hashStr="$(echo "$checksum" | cut -d '-' -f2-)"

if ! command -v "$hashFunc" >/dev/null 2>&1; then
	error "Hash command '$hashFunc' is not available. Exiting."
fi

hashSrc="$(printf '%s' "$src" | "$hashFunc" | cut -d ' ' -f1)"

if [ "$hashSrc" != "$hashStr" ]; then
	return 1
fi
