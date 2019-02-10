#!/bin/sh

# mandatory parameters
action="$1"
path="$2"

# optional parameters

# dependencies
module "colonConfigEvaluated" "https://mdl.sh/colon-config/colon-config-evaluated-0.9.4.sh" "cksum-1078488706"
module "debug" "https://mdl.sh/debug/debug-0.9.1.sh" "cksum-2534568300"
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"
module "githubList" "https://mdl.sh/github/list/github-list-0.9.4.sh" "cksum-1122407272"

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
	debug "No userConfig found at '$userConfig'" "MDL_LIST" 2
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
	debug "Using local repository '$repo'" "MDL_LIST" 1
	cd "$repo/mdl.sh"
	localList "$action" "$path" | sed 's;^./;/;g' | sed 's;/$;;g'
else
	debug "No local repository found" "MDL_LIST" 1
	githubList "$action" "arendtio" "mdl.sh" "$path"
fi
