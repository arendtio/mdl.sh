#!/bin/sh

# check number of arguments
if [ "$#" -ne 2 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
src="$1"
targetHash="$2"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "moduleChecksum" "https://mdl.sh/module/checksum/module-checksum-0.9.5.sh" "cksum-1042210044"

hashFunc="$(printf '%s' "$targetHash" | cut -d '-' -f1)"
srcHash="$(moduleChecksum "$src" "$hashFunc")" || exit 65
if [ "$srcHash" != "$targetHash" ]; then
	exit 1
fi

