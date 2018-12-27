#!/bin/sh
set -eEu

identifier="$1"

eval "$(curl -fsL "https://mdl.sh/latest")"
module "moduleFetch" "https://mdl.sh/module/module-fetch-0.9.5.sh" "cksum-1233830148"
module "moduleScope" "https://mdl.sh/module/module-scope-0.9.0.sh" "cksum-2336156736"
module "identifier" "https://mdl.sh/module/identifier-0.9.0.sh" "cksum-3777144814"

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
