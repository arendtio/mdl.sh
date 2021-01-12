#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
oldModule="$1" # path to file

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
# start module https://mdl.sh/config/colon/colon-config-evaluated/colon-config-evaluated-0.9.8.sh
colonConfigEvaluated() { (
set -eu
# parameters are defined in colon-config

# dependencies
# start module https://mdl.sh/config/colon/colon-config/colon-config-0.9.6.sh
colonConfig() { (
set -eu
# example usage: colonConfig user ~/.example.conf /etc/example.conf anonymous
# key     = user
# config1 = ~/.example.conf
# config2 = /etc/example.conf
# default = anonymous

if [ "$#" -lt 2 ]; then
	printf 'This function requires at least two arguments.\n' >&2
	exit 1
fi

# parameters
# the first parameter must be the key, the last the default value
# in between can be an arbitraty number of config files
# if a key will be found in a config files the later ones will be skipped
key="$1"
shift 1

envVarName="CONFIG_$(printf '%s' "$key" | tr 'a-z-' 'A-Z_')"
# return the value of the corresponding environment variable if it exists
# shellcheck disable=SC2016
eval "$(printf 'if [ ! -z ${%s+x} ]; then printf '"'"'%%s\n'"'"' "${%s}"; exit 0; fi' "$envVarName" "$envVarName")"

# dependencies
# start module https://mdl.sh/config/colon/colon-value/colon-value-0.9.3.sh
colonValue() { (
set -eu
# mandatory parameters
key=$1
file=$2

# check if the file exists
if ! [ -f "$file" ]; then
	exit 1
fi

# extract value for the specific key
grep -e "^$key:" "$file" \
	| cut -d':' -f2- \
	| sed -e 's/^[[:space:]]\{1,\}//g' -e 's/[[:space:]]\{1,\}$//g'
) }
# end module https://mdl.sh/config/colon/colon-value/colon-value-0.9.3.sh
# start module https://mdl.sh/config/colon/colon-value-exists/colon-value-exists-0.9.0.sh
colonValueExists() { (
set -eu
# mandatory parameters
key=$1
file=$2

# check if the file exists
if ! [ -f "$file" ]; then
	exit 1
fi

# try to find the key within the file
grep -e "^$key:" "$file" >/dev/null

# use the return value to signal success and failure
exit $?
) }
# end module https://mdl.sh/config/colon/colon-value-exists/colon-value-exists-0.9.0.sh

# try to find the key in the list of config files
while [ "$#" -gt 1 ]; do
	configFile="$1"
	shift 1

	if [ -f "$configFile" ] && colonValueExists "$key" "$configFile"; then
		colonValue "$key" "$configFile"
		exit 0
	fi
done

# no key found in config files, using default value
defaultValue="$1"
printf '%s\n' "$defaultValue"
) }
# end module https://mdl.sh/config/colon/colon-config/colon-config-0.9.6.sh

value="$(colonConfig "$@")"
eval "printf '%s ' $value | sed 's/ \$//' " # to evaluate variables like: $XDG_DATA_HOME
printf '\n' # and terminate with a newline
) }
# end module https://mdl.sh/config/colon/colon-config-evaluated/colon-config-evaluated-0.9.8.sh
# start module https://mdl.sh/network/services/mdl/find-version/find-version-0.9.9.sh
findVersion() { (
set -eu
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
# start module https://mdl.sh/development/error/error-1.0.4.sh
error() {
# guarantees: intentional-side-effects

# mandatory:
# error message
#msg="$1"

# optional:
# exit code
#code="${2:-1}"

printf '%s\n' "$1" >&2
exit "${2:-1}"
}
# end module https://mdl.sh/development/error/error-1.0.4.sh
# start module https://mdl.sh/network/services/mdl/list/mdl-list-0.9.14.sh
mdlList() { (
set -eu
# mandatory parameters
action="$1"
path="$2"

# optional parameters

# dependencies
# start module https://mdl.sh/config/colon/colon-config-evaluated/colon-config-evaluated-0.9.8.sh
colonConfigEvaluated() { (
set -eu
# parameters are defined in colon-config

# dependencies
# start module https://mdl.sh/config/colon/colon-config/colon-config-0.9.6.sh
colonConfig() { (
set -eu
# example usage: colonConfig user ~/.example.conf /etc/example.conf anonymous
# key     = user
# config1 = ~/.example.conf
# config2 = /etc/example.conf
# default = anonymous

if [ "$#" -lt 2 ]; then
	printf 'This function requires at least two arguments.\n' >&2
	exit 1
fi

# parameters
# the first parameter must be the key, the last the default value
# in between can be an arbitraty number of config files
# if a key will be found in a config files the later ones will be skipped
key="$1"
shift 1

envVarName="CONFIG_$(printf '%s' "$key" | tr 'a-z-' 'A-Z_')"
# return the value of the corresponding environment variable if it exists
# shellcheck disable=SC2016
eval "$(printf 'if [ ! -z ${%s+x} ]; then printf '"'"'%%s\n'"'"' "${%s}"; exit 0; fi' "$envVarName" "$envVarName")"

# dependencies
# start module https://mdl.sh/config/colon/colon-value/colon-value-0.9.3.sh
colonValue() { (
set -eu
# mandatory parameters
key=$1
file=$2

# check if the file exists
if ! [ -f "$file" ]; then
	exit 1
fi

# extract value for the specific key
grep -e "^$key:" "$file" \
	| cut -d':' -f2- \
	| sed -e 's/^[[:space:]]\{1,\}//g' -e 's/[[:space:]]\{1,\}$//g'
) }
# end module https://mdl.sh/config/colon/colon-value/colon-value-0.9.3.sh
# start module https://mdl.sh/config/colon/colon-value-exists/colon-value-exists-0.9.0.sh
colonValueExists() { (
set -eu
# mandatory parameters
key=$1
file=$2

# check if the file exists
if ! [ -f "$file" ]; then
	exit 1
fi

# try to find the key within the file
grep -e "^$key:" "$file" >/dev/null

# use the return value to signal success and failure
exit $?
) }
# end module https://mdl.sh/config/colon/colon-value-exists/colon-value-exists-0.9.0.sh

# try to find the key in the list of config files
while [ "$#" -gt 1 ]; do
	configFile="$1"
	shift 1

	if [ -f "$configFile" ] && colonValueExists "$key" "$configFile"; then
		colonValue "$key" "$configFile"
		exit 0
	fi
done

# no key found in config files, using default value
defaultValue="$1"
printf '%s\n' "$defaultValue"
) }
# end module https://mdl.sh/config/colon/colon-config/colon-config-0.9.6.sh

value="$(colonConfig "$@")"
eval "printf '%s ' $value | sed 's/ \$//' " # to evaluate variables like: $XDG_DATA_HOME
printf '\n' # and terminate with a newline
) }
# end module https://mdl.sh/config/colon/colon-config-evaluated/colon-config-evaluated-0.9.8.sh
# start module https://mdl.sh/development/debug/debug-1.0.0.sh
debug() {
# guarantees: intentional-side-effects
# To understand this code please take a look at the README.md

if [ "$#" -gt 0 ] &&  [ "$(eval "printf '%s\\n' \"\${DEBUG_${3:-${DEBUG_NAMESPACE:-ALL}}:-$(printf '%s' "${DEBUG_ALL:-0}")}\"")" -ge "${2:-1}" ]; then
	printf '%s: %s\n' "${3:-${DEBUG_NAMESPACE:-ALL}}" "$1" >&2
fi
}
# end module https://mdl.sh/development/debug/debug-1.0.0.sh
# start module https://mdl.sh/development/error/error-1.0.4.sh
error() {
# guarantees: intentional-side-effects

# mandatory:
# error message
#msg="$1"

# optional:
# exit code
#code="${2:-1}"

printf '%s\n' "$1" >&2
exit "${2:-1}"
}
# end module https://mdl.sh/development/error/error-1.0.4.sh
# start module https://mdl.sh/network/services/github/list/github-list-0.9.11.sh
githubList() { (
set -eu
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
# start module https://mdl.sh/development/error/error-1.0.4.sh
error() {
# guarantees: intentional-side-effects

# mandatory:
# error message
#msg="$1"

# optional:
# exit code
#code="${2:-1}"

printf '%s\n' "$1" >&2
exit "${2:-1}"
}
# end module https://mdl.sh/development/error/error-1.0.4.sh
# start module https://mdl.sh/development/debug/debug-1.0.0.sh
debug() {
# guarantees: intentional-side-effects
# To understand this code please take a look at the README.md

if [ "$#" -gt 0 ] &&  [ "$(eval "printf '%s\\n' \"\${DEBUG_${3:-${DEBUG_NAMESPACE:-ALL}}:-$(printf '%s' "${DEBUG_ALL:-0}")}\"")" -ge "${2:-1}" ]; then
	printf '%s: %s\n' "${3:-${DEBUG_NAMESPACE:-ALL}}" "$1" >&2
fi
}
# end module https://mdl.sh/development/debug/debug-1.0.0.sh
# start module https://mdl.sh/network/https-get/https-get-1.0.7.sh
httpsGet() { (
set -eu
# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
url="$1"

# dependencies
# start module https://mdl.sh/development/error/error-1.0.4.sh
error() {
# guarantees: intentional-side-effects

# mandatory:
# error message
#msg="$1"

# optional:
# exit code
#code="${2:-1}"

printf '%s\n' "$1" >&2
exit "${2:-1}"
}
# end module https://mdl.sh/development/error/error-1.0.4.sh
# start module https://mdl.sh/development/debug/debug-1.0.0.sh
debug() {
# guarantees: intentional-side-effects
# To understand this code please take a look at the README.md

if [ "$#" -gt 0 ] &&  [ "$(eval "printf '%s\\n' \"\${DEBUG_${3:-${DEBUG_NAMESPACE:-ALL}}:-$(printf '%s' "${DEBUG_ALL:-0}")}\"")" -ge "${2:-1}" ]; then
	printf '%s: %s\n' "${3:-${DEBUG_NAMESPACE:-ALL}}" "$1" >&2
fi
}
# end module https://mdl.sh/development/debug/debug-1.0.0.sh

# The debug module uses this variable
export DEBUG_NAMESPACE="HTTPS_GET"

# check if it is an https url
if [ "$(printf '%s' "$url" | head -c 8 | tr '[:upper:]' '[:lower:]')" != "https://" ]; then
	error "'$url' does not start with 'https://'. Exiting." 65
fi

rc="1"

# find out command- v http client is available and use it
if command -v curl >/dev/null 2>&1; then
	debug "Using curl" 1
	curl -sL "$url"
	rc="$?"
elif command -v wget >/dev/null 2>&1; then
	debug "Using wget" 1
	wget -qO - "$url"
	rc="$?"
elif command -v openssl >/dev/null 2>&1; then
	debug "Using openssl" 1
	host="$(printf '%s\n' "$url" | sed -e 's;^[^/]\{1,\}://;;' -e 's;[/:].*$;;')"
	path="$(printf '%s\n' "$url" | sed -e 's;^[^/]\{1,\}://[^/]\{1,\}/;/;')" # with leading /
	port="$(printf '%s\n' "$url" | sed -e 's;^[^/]\{1,\}://[^/]\{1,\}:\([0-9]\{1,\}\)/.*$;\1;')"
	if [ "$port" = "$url" ]; then
		port="443"
	fi

	# sed to remove the headers from the output
	printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$path" "$host" | openssl s_client -quiet -connect "$host:$port" 2>/dev/null | sed '1,/^\r$/d'
	rc="$?"
elif command -v ftp >/dev/null 2>&1 && [ "$(ftp -h 2>&1 | grep -c http)" -gt 0 ]; then
	# if the cli program 'ftp' exists, we try to find out if it is the correct version (OpenBSD vs. GNU)
	debug "Using ftp" 1
	ftp -o - "$url"
	rc="$?"
else
	error "None of curl, wget and openssl is available. Exiting."
fi

if [ "$rc" -ne 0 ]; then
	debug "Non-zero rc '$rc', replacing it now" 1
	# actually we don't know the exact reason why it failed, but unavailability is the most common/likely
	exit 69
fi
) }
# end module https://mdl.sh/network/https-get/https-get-1.0.7.sh
# start module https://mdl.sh/development/polyfill/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.5.sh
tmpDirByUserKeyword() { (
set -eu
# This module provides an easy way to create a tmp directory
# which can be found by other programs which use the same keyword.

if [ "$#" -ne 1 ]; then
	printf 'Not enough arguments\n' >&2
	exit 1
fi

keyword="$1"

if [ "$keyword" = "" ]; then
	printf 'The keyword must not be empty\n' >&2
	exit 1
fi

# This module depends on mktemp
if ! command -v mktemp >/dev/null 2>&1; then
	printf 'mktemp is unavailable\n' >&2
	exit 1
fi

# macOS gets some special treatment
# $OSTYPE is not part of POSIX
# shellcheck disable=SC2039
if [ "$(printf '%s' "${OSTYPE:-}" | cut -c 1-6)" = "darwin" ]; then
	cmdDry="$(printf "mktemp -t '%s' -u" "$keyword")"
	cmdDir="$(printf "mktemp -d -t '%s'" "$keyword")"
	cmdFile="$(printf "mktemp -t '%s-pointer'" "$keyword")"
else
	# Note: mktemp on android seems to have problems with templates,
	# so we include the template here to trigger the problem early
	cmdDry="$(printf "mktemp -u --tmpdir '%s.XXXX'" "$keyword")"
	cmdDir="$(printf "mktemp -d --tmpdir '%s.XXXX'" "$keyword")"
	cmdFile="$(printf "mktemp --tmpdir '%s-pointer.XXXX'" "$keyword")"
fi

# find the directory that mktemp uses by default
if ! dry="$(eval "$(printf '%s' "$cmdDry")")"; then
	printf 'mktemp dry-run failed\n' >&2
	exit 1
fi

directory="$(dirname "$dry")"

# Set pointer to the same value every time this script gets invoked by the same user
# Note: This should work because in /tmp you can read only your own files

# search pointer value
pointer="$(head -n1 "$directory/$keyword"-pointer* 2>/dev/null || true)"

# create, if it does not exist
if [ "$pointer" = "" ] || [ ! -d "$pointer" ]; then
	for p in "$directory/$keyword"-pointer*; do
		if [ "$p" = "$directory/$keyword-pointer*" ]; then
			continue
		fi
		# warn about existing but non-functional pointers
		printf 'WARNNIG: Found orphaned pointer %s\n' "$p" >&2
	done

	if ! pointer="$(eval "$(printf '%s' "$cmdDir")")"; then
		printf 'mktemp -d "%s.XXXX" failed' "$keyword" >&2
		return $?
	fi
	if ! pointerFile="$(eval "$(printf '%s' "$cmdFile")")"; then
		printf 'mktemp "%s-pointer.XXXX" failed' "$keyword" >&2
		return $?
	fi
	printf '%s\n' "$pointer" >"$pointerFile"
fi

printf '%s\n' "$pointer"
) }
# end module https://mdl.sh/development/polyfill/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.5.sh
# start module https://mdl.sh/development/cache/cache-0.9.7.sh
cache() { (
set -eu
# Make is easy to cache the result of a command
# Example:
# cache -- curl -sL "https://mdl.sh"
# cache -- curl -sL "https://mdl.sh"
# For the first line this modul executes curl, stores the result in the cache folder and writes the result to stdout
# for the second command it just reads the result from the cache folder and writes it to stdout
# The cache uses the md5 hash of the command as a key to identify similar commands

##  Check for Dependencies (md5sum ist actually part of the coreutils, but not POSIX)
## e.g. FreeBSD has md5 but not md5sum
if command -v md5sum >/dev/null 2>&1; then
	hashCommand="md5sum"
elif command -v md5 >/dev/null 2>&1; then
	hashCommand="md5"
else
	printf 'Please install md5sum (coreutils) or md5\n'
	exit 1
fi

# for POSIX compatibility
# start module https://mdl.sh/development/polyfill/POSIX/printfq/printfq-0.9.4.sh
printfq() { (
set -eu
# This module tries to replicate the sh_quote behaivor of printf '%q ' "$@" for data without new lines
# to offer a POSIX compliant alternative
# inspired by https://stackoverflow.com/questions/12162010/posix-sh-equivalent-for-bash-s-printf-q
if [ "$#" -eq 0 ]; then return 0; fi
while :
do
	# take a look at http://git.savannah.gnu.org/gitweb/?p=bash.git;a=blob;f=lib/sh/shquote.c#l337
	CR="$(printf '\r')"
	# sed seems to add a newline on some systems (e.g. macOS)
	printf '%s' "$1" | sed -e 's/\([][ \\	"'"$CR"'|\&;()<>\!\{\}\*\?\^\$`'\'']\)/\\\1/g' -e 's/[^=:]~/\\~/g' | tr -d '\n'
	shift
	# to exactly replicate the output of printf '%q ' "$@" we print the space before the break
	printf ' '
	if [ "$#" -eq 0 ]; then break; fi
done
printf '\n'
) }
# end module https://mdl.sh/development/polyfill/POSIX/printfq/printfq-0.9.4.sh

# Parameter default values
cacheDir="${cacheDir:-./cache}"
keyDict="false"
limitExists="false"
action="cache"
cmd=""

# Parameters
while [ "$#" -gt 0 ]; do
	#printf 'processing an argument: %s\n' "$1"
	if [ "$1" = "-d" ]; then
		cacheDir="$2"
		shift 2
	elif [ "$1" = "-k" ]; then
		keyDict="true"
		shift 1
	elif [ "$1" = "-r" ]; then
		action="reset"
		shift
		break
	elif [ "$1" = "-s" ]; then
		cmd="$2"
		shift 2
	elif [ "$1" = "-t" ]; then
		timeLimit=$2
		limitExists="true"
		shift 2
	elif [ "$1" = "--" ]; then
		shift 1
		break
	elif [ "$(printf '%s' "$1" | cut -c 1)" = "-" ]; then
		printf 'Invalid argument "%s"\n' "$1" >&2
		exit 1
	else
		printf 'Please use the -- argument terminator to avoid ambiguous arguments\n' >&2
		break
	fi
done

if [ "$action" = "reset" ]; then
	if [ -e "$cacheDir" ]; then
		rm -r "$cacheDir"
	fi
	exit 0
fi

#printf 'cache miss\n'
# XXX: HACK: we escape everything but ;
# this should allow most use-cases but I have no idea
# what it breaks... (&&, ||, &, ...)
# if someone has a problem with this implementation there is still -s
if [ "$cmd" = "" ]; then
	#cmd="$(printf "%q " "$@" | sed 's/\\;/;/g')" # bash version
	cmd="$(printfq "$@" | sed 's/\\;/;/g')" # escape everything except ;
fi

cacheKey="$(printf '%s\n' "$cmd" | "$hashCommand" | cut -d" " -f1)"
cacheFile="$cacheDir/$cacheKey"

mkdir -p "$cacheDir"
if [ "$keyDict" = "true" ]; then
	mkdir -p "$cacheDir/keyDict"
fi
hit="false"
if [ -f "$cacheFile" ]; then
	cacheFileTime="$(date -r "$cacheFile" +%s)"
	cacheFileAge="$(( $(date +%s) - cacheFileTime ))"

	if [ "$limitExists" = "false" ] || \
		[ "$cacheFileAge" -le "$timeLimit" ]; then
		hit="true"
	fi
fi

if [ "$keyDict" = "true" ] && [ ! -e "$cacheDir/keyDict/$cacheKey" ]; then
	printf '%s\n' "$cmd" > "$cacheDir/keyDict/$cacheKey"
fi

if [ "$hit" = "false" ]; then
	#printf 'executing: %s' "$cmd" >&2
	eval "$cmd" > "$cacheFile"
	rc="$?"
	#printf 'return Value: %s\n' "$rc"
	if [ "$rc" != "0" ]; then
		rm "$cacheFile"
		exit $rc
	fi
#else
#	printf 'cache hit\n'
fi

cat "$cacheFile"
) }
# end module https://mdl.sh/development/cache/cache-0.9.7.sh

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
) }
# end module https://mdl.sh/network/services/github/list/github-list-0.9.11.sh

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
) }
# end module https://mdl.sh/network/services/mdl/list/mdl-list-0.9.14.sh
# start module https://mdl.sh/development/versions/semver/compare/semver-compare-0.9.2.sh
semverCompare() { (
set -eu
# TODO: add support for (non-numeric) extensions https://semver.org/#spec-item-9

if [ "$#" -ne 3 ]; then
	printf 'Not enough arguments\n'
	exit 127
fi


# mandatory:
versionA="$1"
operator="$2"
versionB="$3"

# returns 0 if the 2nd argument is a greater version than the first
# otherwise if returns 1 (less or equal)
isLess() {
	a="${1#\.}" # remove leading dots
	b="${2#\.}"

	if [ "$a" = "$b" ]; then
		return 1
	fi

	if [ "$a" = "" ]; then
		a1=0
	else
		a1="$(printf '%s\n' "$a" | awk -F '.' '{print $1}')"
	fi

	if [ "$b" = "" ]; then
		b1=0
	else
		b1="$(printf '%s\n' "$b" | awk -F '.' '{print $1}')"
	fi

	if [ "$a1" -lt "$b1" ]; then
		return 0
	elif [ "$a1" -gt "$b1" ]; then
		return 1
	else
		# remove leading digits
		isLess "${a#[^.]*}" "${b#[^.]*}"
		return $?
	fi
}

if [ "$operator" = "isLess" ]; then
	isLess "$versionA" "$versionB"
	exit $?
elif [ "$operator" = "isGreater" ]; then
	# switched order
	isLess "$versionB" "$versionA"
	exit $?
elif [ "$operator" = "isEqual" ]; then
	if ! isLess "$versionA" "$versionB" && ! isLess "$versionB" "$versionA"; then
		exit 0
	else
		exit 1
	fi
else
	printf 'No valid operator "%s".' "$operator"
	exit 127
fi
) }
# end module https://mdl.sh/development/versions/semver/compare/semver-compare-0.9.2.sh

nameFromPath() {
	x="$(printf '%s' "$1" | sed 's;^.*/\([^/\.]*[^0-9]\)\(-[-0-9\.]*\)\{0,1\}\(\.spec\)\{0,1\}\.sh$;\1;g')"
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
	printf '%s\n' "$1" | sed 's/^\([0-9]\{1,\}\)\..*$/\1/'
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
) }
# end module https://mdl.sh/network/services/mdl/find-version/find-version-0.9.9.sh
# start module https://mdl.sh/development/module/checksum/module-checksum-1.0.0.sh
moduleChecksum() { (
set -eu
# check number of arguments
if [ "$#" -gt 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# optional:
# command to calculate the hash, examples:
# cksum (default, POSIX compliant, weak)
# md5sum (fast)
# sha256sum (secure)
hashCmd="${1:-cksum}"

# start module https://mdl.sh/development/error/error-1.0.4.sh
error() {
# guarantees: intentional-side-effects

# mandatory:
# error message
#msg="$1"

# optional:
# exit code
#code="${2:-1}"

printf '%s\n' "$1" >&2
exit "${2:-1}"
}
# end module https://mdl.sh/development/error/error-1.0.4.sh

if ! command -v "$hashCmd" >/dev/null 2>&1; then
	error "Checksum command '$hashCmd' is not available. Exiting." 69
fi

# the content should come from a pipe in order to allow untrimmed whitespace
# as a parameter it is possible too, but putting the whitespace in a
# variable is kinda complicated because sub-shells remove it

printf '%s-' "$hashCmd"
cat - | "$hashCmd" | tr -s '[:blank:]' ' ' | cut -d ' ' -f1
printf '\n'
) }
# end module https://mdl.sh/development/module/checksum/module-checksum-1.0.0.sh
# start module https://mdl.sh/development/error/error-1.0.4.sh
error() {
# guarantees: intentional-side-effects

# mandatory:
# error message
#msg="$1"

# optional:
# exit code
#code="${2:-1}"

printf '%s\n' "$1" >&2
exit "${2:-1}"
}
# end module https://mdl.sh/development/error/error-1.0.4.sh
# start module https://mdl.sh/content/transformer/whitespace-protection/whitespace-protection-0.9.1.sh
whitespaceProtection() { (
set -eu
set -eu

# check number of arguments
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
action="$1"

if [ "$action" = "add" ]; then
	# add the strings before and after the input
	printf '%s' "AAA"
	cat -
	printf '%s' "ZZZ"
elif [ "$action" = "remove" ]; then
	# remove the protection string before and after the content
	input="$(cat -)"
	input="${input#AAA}"
	input="${input%ZZZ}"
	printf '%s' "$input"
else
	printf 'Invalid argument (neither "add" nor "remove")\n' >&2
	exit 64
fi
) }
# end module https://mdl.sh/content/transformer/whitespace-protection/whitespace-protection-0.9.1.sh

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_UPDATE"

# try to update the listed modules
# copy newest version to next version
if [ "$oldModule" = "${oldModule%.spec.sh}" ]; then
	patchVersion="$(printf '%s' "$oldModule" | sed 's;.*\.\([0-9]\{1,\}\)\.sh$;\1;')"
	newModule="$(printf '%s' "$oldModule" | sed 's;\.[0-9]\{1,\}\.sh$;\.;')$((patchVersion + 1)).sh"
else
	newModule="$oldModule"
fi
debug "$oldModule will be updated to $newModule" 1

# regex explanation:
# \1 = whitespace prefix + "module"
# \2 = whitespace after module + first quote
# \3 = function name
# \4 = quotes and whitespace between function name and URL
# \5 = URL
# \6 = should not be used; whole optional checksum part
# \7 = quotes and whitespace after URL
# \8 = checksum
# \9 = whitespace suffix
mdlRegex="$(printf '%s' \
	'^\([[:space:]]*module\)' \
	'\([[:space:]]\{1,\}["'"'"']\{,1\}\)' \
	'\([[:alnum:]]\{1,\}\)' \
	'\([\"'"'"']\{,1\}[[:space:]]\{1,\}["'"'"']\{,1\}\)' \
	'\([^[:space:]"'"'"']\{1,\}\)' \
	'\(' \
		'\([\"'"'"']\{,1\}[[:space:]]\{1,\}["'"'"']\{,1\}\)' \
		'\([^[:space:]"'"'"']\{1,\}\)' \
		'\|' \
	'\)' \
	'\([\"'"'"']\{,1\}[[:space:]]*\)$')"

# '\(\"\([^\"]\{1,\}\)\"\|'"'"'\([^'"'"']\{1,\}\)'"'"'\|\([^[:space:]]\{1,\}\)\)' \

userConfig=${XDG_CONFIG_HOME:-~/.config}/"module.sh/module.conf"
key="local-repository"
repo="$(colonConfigEvaluated "$key" "$userConfig" none)"
if [ "$repo" = "none" ]; then
	error "No local-repository could be found in the config file."
fi

debug "Using local-repo $repo" 1

rewriteLine() { (
	p="$1"
	debug "Line $p" 3
	# check if the line contains a dependency
	if printf '%s\n' "$p" | grep "$mdlRegex" >/dev/null; then
		debug "Dependency Line: $p" 2

		beforeUrl="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\1\\2\\3\\4;")"
		oldUrl="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\5;")"
		beforeChecksum="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\7;")"
		checksum="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\8;")"
		suffix="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\9;")"
		hashFunc="$(printf '%s\n' "$checksum" | sed 's;^\([^-]\{1,\}\)-.*$;\1;')"

		debug "BeforeUrl: $beforeUrl" 3
		debug "OldUrl: $oldUrl" 3
		debug "BeforeChecksum: $beforeChecksum" 3
		debug "Checksum: $checksum" 3
		debug "Suffix: $suffix" 3
		debug "HashFunc: $hashFunc" 3

		# TODO: this is mdl.sh specific. We need a solution for other repos too.
		if [ "$oldUrl" != "${oldUrl%.spec.sh}" ]; then
			# specs should not be dependencies... just in case
			debug "Detected spec '$oldUrl' as dependency in '$oldModule'. Not good." 0
			newDep="$oldUrl"
		else
			oldDep="$(printf '%s' "$oldUrl" | sed 's;^https://[-a-zA-Z0-9_\.:]\{1,\}/;/;')"
			debug "OldDep: $oldDep" 3
			newDep="$(findVersion latestSameMajor "$oldDep" | sed 's;^/;https://mdl.sh/;')"
		fi

		debug "NewDep: $newDep" 3

		if [ "$newDep" = "" ]; then
			error "The newDep for '$oldDep' could not be found in repo '$repo'" 1
			exit 1
		fi

		# the hash part is optional
		if [ "$hashFunc" != "" ]; then
			newDepPath="$(printf '%s/%s' "$repo" "$(printf '%s' "$newDep" | sed 's;^[^\/:]*://;;')")"
			newChecksum="$(moduleChecksum "$hashFunc" <"$newDepPath")"
			debug "NewChecksum: $newChecksum" 3

			printf '%s%s%s%s%s\n' "$beforeUrl" "$newDep" "$beforeChecksum" "$newChecksum" "$suffix"
		else
			debug "No Checksum" 3
			printf '%s%s%s\n' "$beforeUrl" "$newDep" "$suffix"
		fi
	else
		printf '%s\n' "$p"
	fi
) }

# loop the lines of the old file
newContent="$(
	# read $oldModule line-by-line
	# we tunnel the return code through the pipe while applying the whitespace protection
	# https://unix.stackexchange.com/a/70675/130618
	# if this causes trouble in the future, simply applying the whitespace protection before rewriting might be a quick and dirty solution
	# shellcheck disable=SC2086
	( ( ( ( while IFS="" read -r p || [ -n "$p" ]; do
		rewriteLine "$p" || exit $?
	done <"$oldModule"; printf '%s\n' "$?" >&3 ) | whitespaceProtection add >&4 ) 3>&1 ) | (read -r xs; exit $xs) ) 4>&1
)"
rc="$?"
if [ "$rc" -ne 0 ]; then
	error "Rewrite failed." "$rc"
	exit "$rc"
fi

debug "$(printf 'New Module content (rc %s)  (with whitespace protection):\n%s\n' "$rc" "$newContent")" 5

# write new file and print diff
#printf '%s' "$newContent" | diff -u "$oldModule" - || true
# if the file does not exists or is a spec, write it
if [ ! -f "$newModule" ] || [ "$newModule" != "${newModule%.spec.sh}" ]; then
	debug "Writing: '$newModule'" 1
	printf '%s' "$newContent" | whitespaceProtection remove > "$newModule"
	debug "$(diff -u "$oldModule" "$newModule" || true)" 2
else
	error "NewModule '$newModule' exists and is no spec. Aborting." 1
fi
