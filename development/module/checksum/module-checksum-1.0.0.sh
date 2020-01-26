#!/bin/sh

# check number of arguments
if [ "$#" -gt 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# optional:
# command to calculate the hash, examples:
# cksum (default, POSIX compliant, weak)
# md5sum (fast)
# sha256sum (secure)
hashCmd="${1:-cksum}"

module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"

if ! command -v "$hashCmd" >/dev/null 2>&1; then
	error "Checksum command '$hashCmd' is not available. Exiting." 69
fi

# the content should come from a pipe in order to allow untrimmed whitespace
# as a parameter it is possible too, but putting the whitespace in a
# variable is kinda complicated because sub-shells remove it

printf '%s-' "$hashCmd"
cat - | "$hashCmd" | tr -s '[:blank:]' ' ' | cut -d ' ' -f1
printf '\n'
