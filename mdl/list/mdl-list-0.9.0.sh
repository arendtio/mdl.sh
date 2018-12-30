#!/bin/sh

# mandatory parameters
action="$1"
path="$2"

# optional parameters

# dependencies
module "colonConfigEvaluated" "https://mdl.sh/colon-config/colon-config-evaluated-0.9.2.sh" "cksum-2493197259"
module "debug" "https://mdl.sh/debug/debug-0.9.0.sh" "cksum-4035594112"
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"
module "githubList" "https://mdl.sh/github/list/github-list-0.9.0.sh" "cksum-2981403016"
module "tmpDirByUserKeyword" "https://mdl.sh/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.3.sh" "cksum-1384258922"
module "cache" "https://mdl.sh/cache/cache-0.9.4.sh" "cksum-273689623"

# examples:
# list dirs /
# list files /module/tools/spec
# list all /

# check for / at the start of $path
if [ "$path" = "${path#/}" ]; then
	error "The path '$path' does not start with a slash."
	exit 1
fi

# read the config file
repo="none"
userConfig=${XDG_CONFIG_HOME:-~/.config}/"module.sh/module.conf"
if [ -f "$userConfig" ]; then
	key="local-repository"
	repo="$(colonConfigEvaluated "$key" "$userConfig" none)"
else
	debug "No userConfig found at '$userConfig'" "MDL_LIST" 3
fi

# remove trailing / from path (if present)
path="${path%/}"

localList() {
	# $1 action
	# $2 path
	if [ "$1" = "all" ]; then
		ls -dL ".$2"/*
	elif [ "$1" = "dirs" ]; then
		ls -dL ".$2"/*/
	elif [ "$1" = "files" ]; then
		ls -dLp ".$2"/* | grep -v "/$"
	else
		error "The action '$1' is not supported."
	fi
}

# check file existence
if [ "$repo" != "none" ] && [ -d "$repo/mdl.sh" ]; then
	debug "Using local repository '$repo'" "MDL_LIST" 1
	cd "$repo/mdl.sh"
	localList "$action" "$path" | sed 's;^./;/;g' | sed 's;/$;;g'
else
	debug "No local repository found" "MDL_LIST" 1
	# use cache if possible
	if command -v md5sum >/dev/null 2>&1 || command -v md5 >/dev/null 2>&1; then
		# create/find the cache directory
		if cachePointer="$(tmpDirByUserKeyword "mdl-list" 2>/dev/null)"; then
			debug "Using cache directory '$cachePointer'" "MDL_LIST" 1
			# execute with cache
			cache -d "$cachePointer" -- githubList "$action" "arendtio" "mdl.sh" "$path"
		else
			debug "tmpDirByUserKeyword failed" "MDL_LIST" 1
			debug "Using githubList without cache. Mind the github API ratelimit." "MDL_LIST" 0

			githubList "$action" "arendtio" "mdl.sh" "$path"
		fi
	fi

fi
