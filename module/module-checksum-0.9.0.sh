#!/bin/sh

# mandatory:
# content
content="$1"

# optional:
# command to calculate the hash, examples:
# cksum (default, POSIX compliant, weak)
# md5sum (fast)
# sha256sum (secure)
hashCmd="${2:-cksum}"

module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"

if ! command -v "$hashCmd" >/dev/null 2>&1; then
	error "Checksum command '$hashCmd' is not available. Exiting."
fi

printf '%s-' "$hashCmd"
printf '%s' "$content" | "$hashCmd" | cut -d ' ' -f1
printf '\n'

