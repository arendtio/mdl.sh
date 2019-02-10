#!/bin/sh

module() {
	# eval module code
	eval "$(
# start module https://mdl.sh/error/error-1.0.1.sh
error() { (
set -eu
# mandatory:
# error message
msg="$1"

# optional:
# exit code
code="${2:-1}"

echo "$msg" >&2
exit "$code"
) }
# end module https://mdl.sh/error/error-1.0.1.sh
# start module https://mdl.sh/module/module-fetch-0.9.9.sh
moduleFetch() { (
set -eu
# mandatory parameters
url="$1"

# dependencies
# start module https://mdl.sh/colon-config/colon-config-evaluated-0.9.4.sh
colonConfigEvaluated() { (
set -eu
# parameters are defined in colon-config

# dependencies
# start module https://mdl.sh/colon-config/colon-config-0.9.2.sh
colonConfig() { (
set -eu
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

# example usage: colonConfig user ~/.example.conf /etc/example.conf anonymous
# key     = user
# config1 = ~/.example.conf
# config2 = /etc/example.conf
# default = anonymous

# dependencies
# start module https://mdl.sh/colon-config/colon-value-0.9.0.sh
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
	| sed 's/\(^[[:space:]]\+\|[[:space:]]\+$\)//g'
) }
# end module https://mdl.sh/colon-config/colon-value-0.9.0.sh
# start module https://mdl.sh/colon-config/colon-value-exists-0.9.0.sh
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
# end module https://mdl.sh/colon-config/colon-value-exists-0.9.0.sh

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
# end module https://mdl.sh/colon-config/colon-config-0.9.2.sh

value="$(colonConfig "$@")"
eval "printf '%s ' $value | sed 's/ \$//' " # to evaluate variables like: $XDG_DATA_HOME
printf '\n' # and terminate with a newline
) }
# end module https://mdl.sh/colon-config/colon-config-evaluated-0.9.4.sh
# start module https://mdl.sh/https-get/https-get-1.0.1.sh
httpsGet() { (
set -eu
# mandatory:
url="$1"

# start module https://mdl.sh/error/error-1.0.1.sh
error() { (
set -eu
# mandatory:
# error message
msg="$1"

# optional:
# exit code
code="${2:-1}"

echo "$msg" >&2
exit "$code"
) }
# end module https://mdl.sh/error/error-1.0.1.sh

# find out command- v http client is available and use it
if command -v curl >/dev/null 2>&1; then
	curl -sL "$url"
elif command -v wget >/dev/null 2>&1; then
	wget -qO - "$url"
elif command -v openssl >/dev/null 2>&1; then
	host="$(echo "$url" | sed -e 's;^[^/]\+://;;' -e 's;[/:].*$;;')"
	path="$(echo "$url" | sed -e 's;^[^/]\+://[^/]\+/;/;')" # with leading /
	port="$(echo "$url" | sed -e 's;^[^/]\+://[^/]\+:\([0-9]\+\)/.*$;\1;')"
	if [ "$port" = "$url" ]; then
		port="443"
	fi

	# sed to remove the headers form the output
	printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$path" "$host" | openssl s_client -quiet -connect "$host:$port" 2>/dev/null | sed '1,/^\r$/d'
else
	error "None of curl, wget and openssl is available. Exiting."
fi
) }
# end module https://mdl.sh/https-get/https-get-1.0.1.sh
# start module https://mdl.sh/error/error-1.0.1.sh
error() { (
set -eu
# mandatory:
# error message
msg="$1"

# optional:
# exit code
code="${2:-1}"

echo "$msg" >&2
exit "$code"
) }
# end module https://mdl.sh/error/error-1.0.1.sh
# start module https://mdl.sh/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.4.sh
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
# end module https://mdl.sh/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.4.sh
# start module https://mdl.sh/cache/cache-0.9.5.sh
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
	echo "Please install md5sum (coreutils) or md5"
	exit 1
fi

# for POSIX compatibility
# start module https://mdl.sh/printfq/printfq-0.9.3.sh
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
# end module https://mdl.sh/printfq/printfq-0.9.3.sh

# Parameter default values
cacheDir="${cacheDir:-./cache}"
keyDict="false"
limitExists="false"
action="cache"
cmd=""

# Parameters
while [ "$#" -gt 0 ]; do
	#echo "processing an argument: $1"
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
		echo "Invalid argument $1" >&2
		exit 1
	else
		echo "Please use the -- argument terminator to avoid ambiguous arguments" >&2
		break
	fi
done

if [ "$action" = "reset" ]; then
	if [ -e "$cacheDir" ]; then
		rm -r "$cacheDir"
	fi
	exit 0
fi

#echo "cache miss"
# XXX: HACK: we escape everything but ;
# this should allow most use-cases but I have no idea
# what it breaks... (&&, ||, &, ...)
# if someone has a problem with this implementation there is still -s
if [ "$cmd" = "" ]; then
	#cmd="$(printf "%q " "$@" | sed 's/\\;/;/g')" # bash version
	cmd="$(printfq "$@" | sed 's/\\;/;/g')" # escape everything except ;
fi

cacheKey="$(echo "$cmd" | "$hashCommand" | cut -d" " -f1)"
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
	echo "$cmd" > "$cacheDir/keyDict/$cacheKey"
fi

if [ "$hit" = "false" ]; then
	#echo -n "executing: $cmd" >&2
	eval "$cmd" > "$cacheFile"
	rc="$?"
	#echo "return Value: $rc"
	if [ "$rc" != "0" ]; then
		rm "$cacheFile"
		exit $rc
	fi
#else
#	echo "cache hit"
fi

cat "$cacheFile"
) }
# end module https://mdl.sh/cache/cache-0.9.5.sh
# start module https://mdl.sh/debug/debug-0.9.1.sh
debug() { (
set -eu
# Examples
# Printing the debug message every time the function is called:
# debug "Executing this section" 0
#
# Print the debug message only when at least one of DEBUG_ALL or DEBUG_MYSEC is set to a number larger or equal to 2
# debug "Executing this section" "MYSEC" 2

# mandatory:
# error message
msg="$1"

# optional:
# debug section
section="${2:-ALL}"
# debug level when the message should be displayed
level="${3:-1}"

envDebugLevel="$(printf '%s' "${DEBUG_ALL:-0}")"
envDebugSectionLevel="$(eval "printf '%s\\n' \"\${DEBUG_$section:-$envDebugLevel}\"")"
if [ "$envDebugSectionLevel" -ge "$level" ]; then
	printf '%s: %s\n' "$section" "$msg" >&2
fi

# TODO: for 1.0, consider
#	- switching positions of level and section
#	- using DEBUG_NAMESPACE
) }
# end module https://mdl.sh/debug/debug-0.9.1.sh

debug "Getting module from URL '$url'" "MODULE_FETCH" 1

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
			debug "Using local repository '$moduleFile'" "MODULE_FETCH" 1

			# read file
			src="$(cat "$moduleFile")"

			# set executed
			executed="true"
		else
			debug "The module file '$moduleFile' can not be found within the repo '$repo'" "MODULE_FETCH" 3
		fi
	else
		debug "The userConfig '$userConfig' does not seem to contain a value for '$key'" "MODULE_FETCH" 3
	fi
else
	debug "No userConfig found at '$userConfig'" "MODULE_FETCH" 3
fi

# obtain the source code
# use the cache only if md5sum is available
if [ "$executed" = "false" ] && ( command -v md5sum >/dev/null 2>&1 || command -v md5 >/dev/null 2>&1 ); then
	# create/find the cache directory
	if cachePointer="$(tmpDirByUserKeyword "module-cache" 2>/dev/null)"; then
		debug "Using cache directory '$cachePointer'" "MODULE_FETCH" 1
		# execute with cache
		src="$(cache -d "$cachePointer" -- httpsGet "$url")"
		executed="true"
	else
		debug "tmpDirByUserKeyword failed" "MODULE_FETCH" 1
	fi
fi

# if the command was not executed with the cache, we just skip the cache
if [ "$executed" = "false" ]; then
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
	error "For the URL '$url': the first line '$firstLine' is not part of the allowed headers. Exiting."
fi

# write the source code to stdout
printf '%s' "$src"
) }
# end module https://mdl.sh/module/module-fetch-0.9.9.sh
# start module https://mdl.sh/module/module-scope-0.9.1.sh
moduleScope() { (
set -eu
name="$1"
moduleContent="$2"

printf '%s() { (\nset -eu\n%s\n) }\n' "$name" "$moduleContent"
) }
# end module https://mdl.sh/module/module-scope-0.9.1.sh
# start module https://mdl.sh/module/module-validate-0.9.1.sh
moduleValidate() { (
set -eu
src="$1"
targetHash="$2"

# start module https://mdl.sh/module/module-checksum-0.9.0.sh
moduleChecksum() { (
set -eu
# mandatory:
# content
content="$1"

# optional:
# command to calculate the hash, examples:
# cksum (default, POSIX compliant, weak)
# md5sum (fast)
# sha256sum (secure)
hashCmd="${2:-cksum}"

# start module https://mdl.sh/error/error-1.0.1.sh
error() { (
set -eu
# mandatory:
# error message
msg="$1"

# optional:
# exit code
code="${2:-1}"

echo "$msg" >&2
exit "$code"
) }
# end module https://mdl.sh/error/error-1.0.1.sh

if ! command -v "$hashCmd" >/dev/null 2>&1; then
	error "Checksum command '$hashCmd' is not available. Exiting."
fi

printf '%s-' "$hashCmd"
printf '%s' "$content" | "$hashCmd" | cut -d ' ' -f1
printf '\n'
) }
# end module https://mdl.sh/module/module-checksum-0.9.0.sh

hashFunc="$(echo "$targetHash" | cut -d '-' -f1)"
srcHash="$(moduleChecksum "$src" "$hashFunc")"
if [ "$srcHash" != "$targetHash" ]; then
	return 1
fi
) }
# end module https://mdl.sh/module/module-validate-0.9.1.sh

		subShell="true"

		# detect -s and shift
		while getopts "s:" opt; do
			if [ "$opt" = "s" ]; then
				subShell="false"
				shift
			else
				error "invalid flag: $opt"
			fi
		done

		# set other parameters
		name="$1"
		location="$2"
		# optional, but recommended:
		checksum="${3:-}"

		# obtain module source
		src="$(moduleFetch "$location")"

		# validate source
		if [ "$#" -ge 3 ] && ! moduleValidate "$src" "$checksum"; then
			error "Validation of module $name has failed. Exiting."
		fi

		# add module prison (sub-shell)
		if [ "$subShell" = "true" ]; then
			src="$(moduleScope "$name" "$src")"
		fi

		printf '%s' "$src"
	)"
}
