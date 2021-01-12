#!/bin/sh
set -eu

# This tool knows two reasons to mark a module as updatable:
#
# 1. for a dependency exists a newer version
# 2. a dependency can be updated
#
# The module generates a list of all modules (path to file) that should be
# updated. The list is ordered so that updating all packages from top
# to bottom will update all packages in one run.
#
# The function assumes that modulePath ($1) is already the latest version
# of that package.


# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
moduleUrl="$1"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "moduleDependencyExtract" "https://mdl.sh/development/module/dependency/extract/module-dependency-extract-0.9.0.sh" "cksum-1546857054"
module "findVersion" "https://mdl.sh/network/services/mdl/find-version/find-version-0.9.9.sh" "cksum-489523316"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.22.sh" "cksum-1242620769"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_UPDATABLE"

updatable() {
	url="$1"
	modulePath="$(printf '%s' "$url" | sed 's;[a-zA-Z]://[^/]\{1,\}/;/;')"
	debug "Checking updates for '$url'"

	# find dependencies
	dependencies="$(moduleFetch "$url" | moduleDependencyExtract)"

	debug "$(printf 'Dependencies:\n%s\n' "$dependencies")" 3

	# find out if the module requires an update
	moduleRequiresUpdate="false"
	if [ "$dependencies" != "" ]; then
		# find newest version for each dependency (and remove specs)
		newestDependencies="$(
			printf '%s\n' "$dependencies" | while IFS="" read -r dependency; do
				# specs should not be dependencies
				if [ "$dependency" != "${dependency%.spec.sh}" ]; then
					continue
				fi

				# currently we have no module to list non-mdl.sh repositories so we have two cases here
				# TODO: create a module that can list all repositories (e.g. based on local checkouts)
				mdlPath="${dependency#https://mdl.sh}"

				if [ "$dependency" != "$mdlPath" ]; then
					findVersion latestSameMajor "$mdlPath" | sed 's;^/;https://mdl.sh/;'
				else
					error "$DEBUG_NAMESPACE: Repository of '$dependency' cannot be listed (non-mdl.sh). Exiting." 1
				fi
			done
		)"
		rc="$?"
		if [ "$rc" -ne 0 ]; then
			exit "$rc"
		fi

		debug "$(printf 'Newest dependencies:\n%s\n' "$newestDependencies")" 4

		# if any of the dependencies is outdated then this module must be updated (TODO: what happens when all dependencies are up-to-date but there is a spec as a dependency?)
		if [ "$dependencies" != "$newestDependencies" ]; then
			debug "At least one dependency has a newer version already" 2
			moduleRequiresUpdate="true"
		fi

		# check if any dependencies should be updated before us
		updatableDeps="$(
			# mind the subshell
			printf '%s\n' "$newestDependencies" | while IFS="" read -r dependency; do
				updatable "$dependency"
			done
		)"

		if [ "$updatableDeps" != "" ]; then
			# print our dependencies before us
			printf '%s\n' "$updatableDeps"
			debug "$(printf 'At least for one dependency of "%s" a new version can be generated\n' "$(basename "$modulePath")")" 2
			moduleRequiresUpdate="true"
		else
			debug "$(printf 'No dependency needs to be updated for %s\n' "$url")" 3
		fi
	else
		debug "$(printf 'No dependencies at all in %s\n' "$url")" 3
	fi

	if [ "$moduleRequiresUpdate" = "true" ]; then
		debug "$url is UPDATEABLE" 2
		printf '%s\n' "$url"
	fi
}

updatable "$moduleUrl"
