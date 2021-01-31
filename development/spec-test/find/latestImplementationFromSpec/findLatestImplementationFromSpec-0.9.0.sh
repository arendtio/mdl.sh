#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
spec="$1"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "identifier" "https://mdl.sh/development/module/identifier/identifier-0.9.6.sh" "cksum-1159040086"
module "mdlList" "https://mdl.sh/network/services/mdl/list/mdl-list-0.9.14.sh" "cksum-1439844879"
module "semverCompare" "https://mdl.sh/development/versions/semver/compare/semver-compare-0.9.2.sh" "cksum-2204597090"

export DEBUG_NAMESPACE="FIND_LATEST_IMPLEMENTATION_FROM_SPEC"

specIdentifier="$(identifier "$spec")"
# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
	error "Invalid spec identifier" 65
fi

debug "specIdentifier: $specIdentifier" 1

# check if the identifier ends with .spec.sh
if [ "${specIdentifier%%.spec.sh}" = "$specIdentifier" ]; then
	error "The provided identifier is not a spec" 65
fi

# extract the path to the module folder
path="$(printf '%s' "$specIdentifier" | sed -e 's;^https://mdl.sh;;g' -e 's;/spec/[^/]*.spec.sh$;;g')"
debug "path: $path" 2

# extract name part from spec name
baseName="$(printf '%s' "$specIdentifier" | sed 's;^.*/\([^/]*\)\(-[-0-9\.]*\).spec.sh$;\1;g')"
if [ "$baseName" = "$specIdentifier" ]; then
	baseName="$(printf '%s' "$specIdentifier" | sed 's;^.*/\([^/]*\).spec.sh$;\1;g')"
fi
debug "baseName: $baseName" 2

# extract version part from spec name
specVersion="$(printf '%s' "$specIdentifier" | sed 's;^.*/[^/]*-\([0-9\.]*\).spec.sh$;\1;g')"
if [ "$specVersion" = "$specIdentifier" ]; then
	specVersion=""
fi
debug "specVersion: $specVersion" 2

maxVersion="0.0.-1"
impPath="$(mdlList "files" "$path" | while IFS="" read -r i || [ -n "$i" ]; do
	iName="$(printf '%s' "$i" | sed 's;^.*/\([^/]*\)\(-[-0-9\.]*\).sh$;\1;g')"
	iVersion="$(printf '%s' "$i" | sed 's;^.*/[^/]*-\([0-9\.]*\)sh$;\1;g')"
	debug "candidate: $iName version: $iVersion" 3
	if [ "$baseName" = "$iName" ]; then
		length="$(printf '%s' "$specVersion" | wc -c | sed 's/^[[:space:]]*//g')"
		debug "specVersion '$specVersion' length '$length'" 3
		# check if the spec is defined for this implementation version
		if [ "$specVersion" = "" ] || [ "$(printf '%s' "$iVersion" | cut -c1-"$length")" = "$specVersion" ]; then
			if semverCompare "$iVersion" isGreater "$maxVersion"; then
				printf '%s\n' "$i"
				maxVersion="$iVersion"
			fi
		fi
	fi
done | tail -n 1)"

printf 'https://mdl.sh%s' "$impPath"

