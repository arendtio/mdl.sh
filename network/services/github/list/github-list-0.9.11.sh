#!/bin/sh

# NOTE: Be aware that this implementation uses an API that
# is rate-limited to 60 requests per hour and ip.
# https://developer.github.com/v3/

if [ "$#" -lt 4 ]; then
	printf 'Too few arguments.\n' >&2
	exit 1;
fi

# mandatory parameters
action="$1"
userName="$2"
repo="$3"
path="$4"

# dependencies
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "httpsGet" "https://mdl.sh/network/https-get/https-get-1.0.7.sh" "cksum-3125334388"
module "tmpDirByUserKeyword" "https://mdl.sh/development/polyfill/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.5.sh" "cksum-196354321"
module "cache" "https://mdl.sh/development/cache/cache-0.9.7.sh" "cksum-1156111666"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="GITHUB_LIST"

if [ "$action" != "all" ] && [ "$action" != "files" ] && [ "$action" != "dirs" ]; then
	error "Invalid action '$action'. Valid actions are 'all', 'files' and 'dirs'."
	exit 1
fi

# $path must start with a slash
if [ "$path" = "${path#/}" ]; then
	error "The path '$path' must start with a slash."
	exit 1
fi

url="https://api.github.com/repos/$userName/$repo/contents$path"
json=""

# use cache if possible
if command -v md5sum >/dev/null 2>&1 || command -v md5 >/dev/null 2>&1; then
	# create/find the cache directory
	if cachePointer="$(tmpDirByUserKeyword "github-list" 2>/dev/null)"; then
		# execute with cache
		debug "Using cache directory '$cachePointer'" 1
		json="$(cache -d "$cachePointer" -t $((60 * 60 * 24)) -- httpsGet "$url")"
	else
		debug "tmpDirByUserKeyword failed" 1
	fi
else
	debug "Neither md5sum nor md5 seems to be available. Skipping cache." 1
fi

if [ "$json" = "" ]; then
	debug "Using Github API without cache. Mind the ratelimit." 0
	json="$(httpsGet "$url")"
fi

# transform it to something more csv like, by
# - reducing leading spaces to one space
# - removing all new-lines
# - adding new-lines after every '},'
#   - Note: some sed version do not support \n:
#     http://sed.sourceforge.net/sedfaq4.html#s4.1
# - extracting the path and type for every line
csv="$(printf '%s' "$json" \
	| sed 's/^ */ /g' \
	| tr -d '\n' \
	| sed "$(printf 's/},/},\\\n/g')" \
	| sed 's/^.*"path": *"\([^"]*\)".*"type": *"\([^"]*\)".*$/\2|\1/g')"

if [ "$action" = "all" ]; then
	printf '%s\n' "$csv" | awk -F '|' '{print "/"$2}'
elif [ "$action" = "dirs" ]; then
	# NOTE: ~ seems to be more portable than == (awk)
	printf '%s\n' "$csv" | awk -F '|' '$1 ~ /^dir$/ {print "/"$2}'
elif [ "$action" = "files" ]; then
	printf '%s\n' "$csv" | awk -F '|' '$1 ~ /^file$/ {print "/"$2}'
fi
