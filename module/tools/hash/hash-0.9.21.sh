#!/bin/sh
set -eu

# mandatory:
identifier="$1"

# optional
hashFunc="${2:-cksum}"

eval "$(curl -fsL "https://mdl.sh/latest")"
module "moduleFetch" "https://mdl.sh/module/fetch/module-fetch-0.9.16.sh" "cksum-3154089636"
module "identifier" "https://mdl.sh/module/identifier/identifier-0.9.3.sh" "cksum-604581518"
module "moduleChecksum" "https://mdl.sh/module/checksum/module-checksum-0.9.5.sh" "cksum-1042210044"

# transform identifier to location
location="$(identifier "$identifier")"

# printf location
printf 'Obtaining content from "%s":\n' "$location"

# obtain content from $location
# NOTE: removed support for moduleLocal
content="$(moduleFetch "$location")"
moduleStr="module"

# extract moduleName from $location
moduleName="$(printf '%s\n' "$location" | sed -e 's;.*/\([^/]*\)-[^/-]*$;\1;' -e 's/-static$//' -e 's/-test$//' -e 's/-\([a-z]\)/\u\1/g')"

# calculate checksum
checksum="$(moduleChecksum "$content" "$hashFunc")"

# display parts of the content
printf '%s\n' "$content" | head -n5
printf '================================\n'
printf '%s\n' "$content" | tail -n5

printf '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\n'

# print module line
printf '%s "%s" "%s" "%s"\n' "$moduleStr" "$moduleName" "$location" "$checksum"
