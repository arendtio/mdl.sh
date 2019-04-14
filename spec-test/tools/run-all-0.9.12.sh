#!/bin/sh
set -eu

# Every package should have a sub-dir called specs comtaining the tests for all versions
# to run a test you need the test file and a matching implementation module

# Obtain module.sh (if necessary)
# and placing them in a central point to avoid redownloading it for every test
tempDir="$(mktemp -d)"
moduleFile="$tempDir/module-latest.sh"

if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then
	# use the local version if possible
	printf '%s\n' "$(module init)" > "$moduleFile"
else
	# otherwise use the online version
	h=mdl.sh;
	p=/latest;
	url="https://$h$p"
	printf '%s' "$(	curl -fsL "$url" || wget -q "$url" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )" >"$moduleFile" 2>/dev/null

fi

# load module.sh for this instance
# this file is also being used in the wrapper
. "$moduleFile"

# dependencies
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"
module "mdlList" "https://mdl.sh/mdl/list/mdl-list-0.9.10.sh" "cksum-3043580583"
module "semverCompare" "https://mdl.sh/semver-compare/semver-compare-0.9.1.sh" "cksum-982949028"

# The debug module uses this variable
export DEBUG_NAMESPACE="RUN_ALL_TESTS"

findSpecPairs() { (
	path="$1"
	debug "findSpecPairs for path '$path'" 1
	mdlList "dirs" "$path" | while IFS="" read -r p || [ -n "$p" ]; do
		# if the directory is called spec
		if [ "$p" != "${p%/spec}" ]; then
			debug "findSpecPairs found spec dir '$p'" 3
			mdlList "files" "$p" | while IFS="" read -r spec || [ -n "$spec" ]; do
				debug "findSpecPairs found spec '$spec'" 2
				# extract name part from spec name
				baseName="$(printf '%s' "$spec" | sed 's;^.*/\([^/]*\)\(-[-0-9\.]*\).spec.sh$;\1;g')"
				if [ "$baseName" = "$spec" ]; then
					baseName="$(printf '%s' "$spec" | sed 's;^.*/\([^/]*\).spec.sh$;\1;g')"
				fi
				debug "findSpecPairs spec baseName '$baseName'" 4
				# extract version part from spec name
				specVersion="$(printf '%s' "$spec" | sed 's;^.*/[^/]*-\([0-9\.]*\).spec.sh$;\1;g')"
				if [ "$specVersion" = "$spec" ]; then
					specVersion=""
				fi
				debug "findSpecPairs specVersion '$specVersion'" 4
				# find a matching implementation in the parent directory
				implementation="$(findImplementationForSpec "$path" "$baseName" "$specVersion")"
				printf 'https://mdl.sh%s|https://mdl.sh%s\n' "$spec" "$implementation"
			done
		else
			# recursion
			findSpecPairs "$p"
		fi
	done
) }

findImplementationForSpec() { (
	path="$1"
	baseName="$2"
	specVersion="$3"

	debug "findImplementationForSpec $*" 2
	maxVersion="0.0.0"
	mdlList "files" "$path" | while IFS="" read -r i || [ -n "$i" ]; do
		iName="$(printf '%s' "$i" | sed 's;^.*/\([^/]*\)\(-[-0-9\.]*\).sh$;\1;g')"
		iVersion="$(printf '%s' "$i" | sed 's;^.*/[^/]*-\([0-9\.]*\)sh$;\1;g')"
		if [ "$baseName" = "$iName" ]; then
			length="$(printf '%s' "$specVersion" | wc -c | sed 's/^[[:space:]]*//g')"
			debug "findImplementationForSpec specVersion '$specVersion' length '$length' " 3
			# check if the spec is defined for this implementation version
			if [ "$specVersion" = "" ] || [ "$(printf '%s' "$iVersion" | cut -c1-"$length")" = "$specVersion" ]; then
				if semverCompare "$iVersion" isGreater "$maxVersion"; then
					printf '%s\n' "$i"
					maxVersion="$iVersion"
				fi
			fi
		fi
	done | tail -n1
) }

reportTest() {
	printf '%s... ' "$(basename "$2")"
	if /bin/sh -c "$wrapper" -- "$@"; then
		printf 'passed\n'
	else
		printf 'FAILED\n'
	fi
}

# Wrapper explanation:
# Tests are meant to be normal modules and use their exit code
# to communicate their exit status. Sadly, functions executed
# within conditional clauses are not run with `set -e` even
# if they explicitely request so.

# To solve that dilemma we start the test in a separate shell
# using this wrapper.

# shellcheck disable=SC2016
wrapper="$(printf '%s\n' \
'set -eu
[ "$(command -v module | cut -c1)" != "m" ] && eval "$(cat "'"$moduleFile"'")"
module "specTestRun" "https://mdl.sh/spec-test/run/spec-test-run-0.9.4.sh" "cksum-4013713265"
specTestRun "$@"')"

# Executing main script
printf 'Searching for specs... '
specList="$(findSpecPairs /)"
printf 'done\n\n'
debug "$(printf 'SpecList:\n%s\n' "$specList")" 1
printf 'Validating implementations with specs:\n'
printf '%s' "$specList" | while IFS="" read -r pair || [ -n "$pair" ]; do
	reportTest \
		"$(printf '%s\n' "$pair" | awk -F'|' '{print $1}')" \
		"$(printf '%s\n' "$pair" | awk -F'|' '{print $2}')"
done

# removing tmp module.sh
if [ -f "$moduleFile" ]; then
	rm "$moduleFile"
fi
