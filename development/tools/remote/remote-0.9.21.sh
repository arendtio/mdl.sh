#!/bin/sh
set -eu

identifier="$1"

eval "$(curl -fsL "https://mdl.sh/latest")"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.21.sh" "cksum-2848792046"
module "moduleScope" "https://mdl.sh/development/module/scope/module-scope-0.9.4.sh" "cksum-4293153131"
module "identifier" "https://mdl.sh/development/module/identifier/identifier-0.9.6.sh" "cksum-1159040086"

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
