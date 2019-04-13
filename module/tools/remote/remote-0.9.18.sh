#!/bin/sh
set -eu

identifier="$1"

eval "$(curl -fsL "https://mdl.sh/latest")"
module "moduleFetch" "https://mdl.sh/module/fetch/module-fetch-0.9.15.sh" "cksum-626475234"
module "moduleScope" "https://mdl.sh/module/scope/module-scope-0.9.3.sh" "cksum-424520902"
module "identifier" "https://mdl.sh/module/identifier/identifier-0.9.2.sh" "cksum-2107256927"

# transform identifier to location
location="$(identifier "$identifier")"

# obtain content from $location
if [ "$(printf '%s' "$location" | head -c 5 | tr '[:upper:]' '[:lower:]')" = "https" ]; then
	content="$(moduleFetch "$location")"
else
	content="$(cat "$location")"
fi

# wrap module
src="$(moduleScope "remoteExecution" "$content")"

# load module
eval "$src"

# remove the script as positional parameter
shift 1

# execute module
remoteExecution "$@"
