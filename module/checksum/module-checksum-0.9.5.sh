#!/bin/sh

# check number of arguments
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory:
# content
content="$1"

# optional:
# command to calculate the hash, examples:
# cksum (default, POSIX compliant, weak)
# md5sum (fast)
# sha256sum (secure)
hashCmd="${2:-cksum}"

module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"

if ! command -v "$hashCmd" >/dev/null 2>&1; then
	error "Checksum command '$hashCmd' is not available. Exiting." 69
fi

printf '%s-' "$hashCmd"
printf '%s' "$content" | "$hashCmd" | tr -s '[:blank:]' ' ' | cut -d ' ' -f1
printf '\n'
