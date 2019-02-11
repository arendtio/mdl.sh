#!/bin/sh
set -eu

# mandatory:
identifier="$1"

# optional
hashFunc="${2:-cksum}"

eval "$(curl -fsL "https://mdl.sh/latest")"
module "moduleFetch" "https://mdl.sh/module/module-fetch-0.9.11.sh" "cksum-3718150028"
module "identifier" "https://mdl.sh/module/identifier-0.9.0.sh" "cksum-3777144814"
module "moduleChecksum" "https://mdl.sh/module/module-checksum-0.9.0.sh" "cksum-24661179"

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
checksum="$(moduleChecksum "$content")"

# display parts of the content
printf '%s\n' "$content" | head -n5
printf '================================\n'
printf '%s\n' "$content" | tail -n5

printf '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\n'

# print module line
printf '%s "%s" "%s" "%s"\n' "$moduleStr" "$moduleName" "$location" "$checksum"