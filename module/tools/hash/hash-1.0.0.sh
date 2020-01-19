#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
identifier="$1"

# optional parameters
hashFunc="${2:-cksum}"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "moduleFetch" "https://mdl.sh/module/fetch/module-fetch-0.9.20.sh" "cksum-78205726"
module "identifier" "https://mdl.sh/module/identifier/identifier-0.9.5.sh" "cksum-3208074111"
module "moduleChecksum" "https://mdl.sh/module/checksum/module-checksum-1.0.0.sh" "cksum-2687740792"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"
module "whitespaceProtection" "https://mdl.sh/text/whitespace-protection/whitespace-protection-0.9.0.sh" "cksum-80238495"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_HASH"

# transform identifier to location
location="$(identifier "$identifier")"
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
	error "Invalid identifier" 65
fi

# printf location
printf 'Obtaining content from "%s":\n' "$location"

# obtain content from $location
# NOTE: removed support for moduleLocal
contentProtected="$(moduleFetch "$location" | whitespaceProtection add)"
moduleStr="module"

# extract moduleName from $location
moduleName="$(printf '%s\n' "$location" | sed -e 's;.*/\([^/]*\)-[^/-]*$;\1;' -e 's/-static$//' -e 's/-test$//' -e 's/-\([a-z]\)/\u\1/g')"

debug "Content to be checksumed: $(printf '%s' "$contentProtected" | whitespaceProtection remove)" 1

# calculate checksum
checksum="$(printf '%s' "$contentProtected" | whitespaceProtection remove | moduleChecksum "$hashFunc")"
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
	error "Invalid hash function" 69
fi

# display parts of the content
printf '%s' "$contentProtected" | whitespaceProtection remove | head -n5
printf '================================\n'
printf '%s' "$contentProtected" | whitespaceProtection remove | tail -n5

printf '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\n'

# print module line
printf '%s "%s" "%s" "%s"\n' "$moduleStr" "$moduleName" "$location" "$checksum"
