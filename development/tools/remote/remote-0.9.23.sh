#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
identifier="$1"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi

module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.22.sh" "cksum-1242620769"
module "moduleScope" "https://mdl.sh/development/module/scope/module-scope-0.9.4.sh" "cksum-4293153131"
module "identifier" "https://mdl.sh/development/module/identifier/identifier-0.9.6.sh" "cksum-1159040086"

# transform identifier to location
location="$(identifier "$identifier")"

# obtain content from $location
content="$(moduleFetch "$location")"

# wrap module
src="$(moduleScope "remoteExecution" "$content")"

# load module
eval "$src"

# remove the script as positional parameter
shift 1

# execute module
remoteExecution "$@"
