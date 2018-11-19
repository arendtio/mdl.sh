#!/bin/sh

module "httpsGet" "https://mdl.sh/https-get/https-get-1.0.1.sh" "cksum-744847999"
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"
module "tmpDirByUserKeyword" "https://mdl.sh/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.3.sh" "cksum-1384258922"
module "cache" "https://mdl.sh/cache/cache-0.9.4.sh" "cksum-273689623"
module "debug" "https://mdl.sh/debug/debug-0.9.0.sh" "cksum-4035594112"

url="$1"

# obtain the source code
# use the cache only if md5sum is available
executed="false"
if command -v md5sum >/dev/null 2>&1 || command -v md5 >/dev/null 2>&1; then
	# create/find the cache directory
	if cachePointer="$(tmpDirByUserKeyword "module-cache" 2>/dev/null)"; then
		debug "Cache directory '$cachePointer'" "MODULE_FETCH" 1
		# execute with cache
		src="$(cache -d "$cachePointer" -- httpsGet "$url")"
		executed="true"
	else
		debug "tmpDirByUserKeyword failed" "MODULE_FETCH" 1
	fi
fi

# if the command was not executed with the cache, we just skip the cache
if [ "$executed" == "false" ]; then
	debug "Getting module without cache" "MODULE_FETCH" 1
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
firstLine="$(echo "$src" | head -n1)"
if ! (echo "$resourceShebangs" | grep -F -q -x "$firstLine") ; then
	error "The first line '$firstLine' is not part of the allowed headers. Exiting."
fi

# write the source code to stdout
printf '%s' "$src"
