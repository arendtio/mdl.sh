#!/bin/sh

# mandatory parameters
url="$1"

# dependencies
module "colonConfigEvaluated" "https://mdl.sh/colon-config/colon-config-evaluated-0.9.6.sh" "cksum-2943954834"
module "httpsGet" "https://mdl.sh/https-get/https-get-1.0.5.sh" "cksum-3010855775"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "tmpDirByUserKeyword" "https://mdl.sh/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.4.sh" "cksum-898459255"
module "cache" "https://mdl.sh/cache/cache-0.9.6.sh" "cksum-1914362764"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_FETCH"

debug "Getting module from URL '$url'" 1

executed="false"

# check for the local repository
userConfig=${XDG_CONFIG_HOME:-~/.config}/"module.sh/module.conf"
if [ -f "$userConfig" ]; then
	key="local-repository"
	repo="$(colonConfigEvaluated "$key" "$userConfig" none)"
	if [ "$repo" != "none" ]; then
		# convert url
		moduleFile="$repo/$(printf '%s' "$url" | sed 's;^[^\/:]*://;;')"

		# check file existence
		if [ -f "$moduleFile" ]; then
			debug "Using local repository '$moduleFile'" 1

			# read file
			src="$(cat "$moduleFile")"

			# set executed
			executed="true"
		else
			debug "The module file '$moduleFile' can not be found within the repo '$repo'" 3
		fi
	else
		debug "The userConfig '$userConfig' does not seem to contain a value for '$key'" 3
	fi
else
	debug "No userConfig found at '$userConfig'" 3
fi

# obtain the source code
# use the cache only if md5sum is available
if [ "$executed" = "false" ] && ( command -v md5sum >/dev/null 2>&1 || command -v md5 >/dev/null 2>&1 ); then
	# create/find the cache directory
	if cachePointer="$(tmpDirByUserKeyword "module-cache" 2>/dev/null)"; then
		debug "Using cache directory '$cachePointer'" 1
		# execute with cache
		src="$(cache -d "$cachePointer" -- httpsGet "$url")"
		executed="true"
	else
		debug "tmpDirByUserKeyword failed" 1
	fi
fi

# if the command was not executed with the cache, we just skip the cache
if [ "$executed" = "false" ]; then
	debug "Getting module without cache" 1
	src="$(httpsGet "$url")"
fi

# In order to elimiate common server errors we check for the script header
# (not as good as checksums, but better than nothing)
resourceShebangs='#!/usr/bin/env bash
#!/usr/bin/env sh
#!/bin/bash
#!/bin/sh
#!/usr/bin/bash
#!/usr/bin/sh'
firstLine="$(printf '%s\n' "$src" | head -n1)"
if ! (printf '%s\n' "$resourceShebangs" | grep -F -q -x "$firstLine") ; then
	error "For the URL '$url': the first line '$firstLine' is not part of the allowed headers. Exiting."
fi

# write the source code to stdout
printf '%s' "$src"
