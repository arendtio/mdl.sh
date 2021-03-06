#!/bin/sh

# mandatory parameters
action="$1"
path="$2"

# optional parameters

# dependencies
module "colonConfigEvaluated" "https://mdl.sh/config/colon/colon-config-evaluated/colon-config-evaluated-0.9.8.sh" "cksum-1865011839"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "githubList" "https://mdl.sh/network/services/github/list/github-list-0.9.11.sh" "cksum-4213378041"

# examples:
# list dirs /
# list files /module/tools/spec
# list all /

# The debug module uses this variable
export DEBUG_NAMESPACE="MDL_LIST"

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
	debug "No userConfig found at '$userConfig'" 2
fi

# remove trailing / from path (if present and the path is not just '/')
if [ "$path" != "/" ]; then
	path="${path%/}"
fi

localList() {
	# $1 action
	# $2 path
	if [ "$2" = "/" ]; then
		localListPath="./"
	else
		localListPath=".$2/"
	fi

	if [ "$1" = "all" ]; then
		ls -dL "$localListPath"* 2>/dev/null || true
	elif [ "$1" = "dirs" ]; then
		ls -dL "$localListPath"*/ 2>/dev/null || true
	elif [ "$1" = "files" ]; then
		ls -dLp "$localListPath"* 2>/dev/null | grep -v "/$" || true
	else
		error "The action '$1' is not supported."
	fi
}

# check file existence
if [ "$repo" != "none" ] && [ -d "$repo/mdl.sh" ]; then
	debug "Using local repository '$repo'" 1
	cd "$repo/mdl.sh"
	localList "$action" "$path" | sed 's;^./;/;g' | sed 's;/$;;g'
else
	debug "No local repository found" 1
	githubList "$action" "arendtio" "mdl.sh" "$path"
fi
