#!/bin/sh

# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
url="$1"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "colonConfigEvaluated" "https://mdl.sh/config/colon/colon-config-evaluated/colon-config-evaluated-0.9.8.sh" "cksum-1865011839"
module "httpsGet" "https://mdl.sh/network/https-get/https-get-1.0.7.sh" "cksum-3125334388"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "tmpDirByUserKeyword" "https://mdl.sh/development/polyfill/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.5.sh" "cksum-196354321"
module "cache" "https://mdl.sh/development/cache/cache-0.9.7.sh" "cksum-1156111666"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "whitespaceProtection" "https://mdl.sh/content/transformer/whitespace-protection/whitespace-protection-0.9.2.sh" "cksum-3680921059"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_FETCH"

# check if it is an https url
if [ "$(printf '%s' "$url" | head -c 8 | tr '[:upper:]' '[:lower:]')" != "https://" ]; then
	error "'$url' does not start with 'https://'. Exiting." 65
fi

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
			src="$(whitespaceProtection add <"$moduleFile")"

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
		# tunnel the return value of httpsGet through the pipe:
		# https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another/70675#70675
		# shellcheck disable=SC2086
		src="$( ( ( ( ( cache -d "$cachePointer" -s "httpsGet '$url'"; printf '%s\n' "$?" >&3 ) | whitespaceProtection add >&4 ) 3>&1 ) | ( read -r rc ; exit $rc ) ) 4>&1; )" || exit $?
		executed="true"
	else
		debug "tmpDirByUserKeyword failed" 1
	fi
fi

# if the command was not executed with the cache, we just skip the cache
if [ "$executed" = "false" ]; then
	debug "Getting module without cache" 1
	# same return code tunnel as 10 lines above
	src="$( ( ( (httpsGet "$url"; printf '%s' "$?" >&3 ) | whitespaceProtection add >&4) 3>&1) | ( read -r rc ; exit "$rc" ) 4>&1; )" || exit $?
fi

# In order to elimiate common server errors we check for the script header
# (not as good as checksums, but better than nothing)
resourceShebangs='#!/usr/bin/env bash
#!/usr/bin/env sh
#!/bin/bash
#!/bin/sh
#!/usr/bin/bash
#!/usr/bin/sh'
firstLine="$(printf '%s' "$src" | whitespaceProtection remove | head -n1)"
if ! (printf '%s\n' "$resourceShebangs" | grep -F -q -x "$firstLine") ; then
	error "For the URL '$url': the first line '$firstLine' is not part of the allowed headers. Exiting." 65
fi

# write the source code to stdout
printf '%s' "$src" | whitespaceProtection remove
