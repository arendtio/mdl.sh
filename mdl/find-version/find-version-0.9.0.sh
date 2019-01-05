#!/bin/sh

# check for number of arguments
if [ "$#" -lt 2 ]; then
	printf 'Not enough arguments given.\n' >&2
	exit 1
fi

# mandatory parameters
action="$1"

# optional parameters
# the depend on the action

# dependencies
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"
module "mdlList" "https://mdl.sh/mdl/list/mdl-list-0.9.5.sh" "cksum-3840375925"
module "semverCompare" "https://mdl.sh/semver-compare/semver-compare-0.9.0.sh" "cksum-3471705375"

nameFromPath() {
	x="$(printf '%s' "$1" | sed 's;^.*/\([^/\.]*[^0-9]\)\(-[-0-9\.]*\)\?\(\.spec\)\?\.sh$;\1;g')"
	if [ "$x" != "$1" ]; then
		printf '%s\n' "$x"
	else
		error "Could not determine the name from path '$1'" 1
	fi
}

versionFromPath() {
	x="$(printf '%s' "$1" | sed 's;^.*/[^/\.]*-\([0-9\.]*\)\.sh$;\1;g')"
	if [ "$x" != "$1" ]; then
		printf '%s\n' "$x"
	fi
}

majorFromVersion() {
	printf '%s\n' "$1" | sed 's/^\([0-9]\+\)\..*$/\1/'
}

if [ "$action" = "latestSameMajor" ]; then
	path="$2"

	name="$(nameFromPath "$path")"
	version="$(versionFromPath "$path")"
	major="$(majorFromVersion "$version")"

	dir="$(dirname "$path")"
	max="0.0.0"
	mdlList "files" "$dir" | while IFS="" read -r entry || [ -n "$entry" ]; do
		if moduleName="$(nameFromPath "$entry" 2>/dev/null)"; then
			moduleVersion="$(versionFromPath "$entry")"
			moduleMajor="$(majorFromVersion "$moduleVersion")"
			if [ "$moduleName" = "$name" ] \
				&& [ "$major" = "$moduleMajor" ] \
				&& semverCompare "$moduleVersion" isGreater "$max"; then
				max="$moduleVersion"
				printf '%s\n' "$entry"
			fi
		fi
	done | tail -n 1
elif [ "$action" = "nameFromPath" ]; then
	nameFromPath "$2"
elif [ "$action" = "versionFromPath" ]; then
	versionFromPath "$2"
elif [ "$action" = "majorFromVersion" ]; then
	majorFromVersion "$2"
else
	error "Invalid action '$action' given."
fi
