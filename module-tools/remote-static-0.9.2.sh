#!/bin/sh
set -eEu

identifier="$1"

eval "$(curl -fsL "https://mdl.sh/latest")"
# start module https://mdl.sh/module/module-fetch-0.9.2.sh
moduleFetch() {(
# start module https://mdl.sh/https-get/https-get-1.0.1.sh
httpsGet() {(
# mandatory:
url="$1"

# start module https://mdl.sh/error/error-1.0.1.sh
error() {(
# mandatory:
# error message
msg="$1"

# optional:
# exit code
code="${2:-1}"

echo "$msg" >&2
exit "$code"
)}
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
)}
# end module https://mdl.sh/https-get/https-get-1.0.1.sh
# start module https://mdl.sh/error/error-1.0.1.sh
error() {(
# mandatory:
# error message
msg="$1"

# optional:
# exit code
code="${2:-1}"

echo "$msg" >&2
exit "$code"
)}
# end module https://mdl.sh/error/error-1.0.1.sh
# start module https://mdl.sh/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.2.sh
tmpDirByUserKeyword() {(
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

# find the directory that mktemp uses by default
# Note: mktemp on android seems to have problems with templates,
# so we include the template here to catch the problem early
if ! dry="$(mktemp -u --tmpdir "$keyword.XXXX")"; then
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

	# mktemp -t does not seem to be supported by the android version of mktemp
	# but is also not necessary
	if ! pointer="$(mktemp -d -p "$directory" "$keyword.XXXX")"; then
		printf 'mktemp -d "%s.XXXX" failed' "$keyword" >&2
		return $?
	fi
	if ! pointerFile="$(mktemp -p "$directory" "$keyword-pointer.XXXX")"; then
		printf 'mktemp "%s-pointer.XXXX" failed' "$keyword" >&2
		return $?
	fi
	printf '%s\n' "$pointer" >"$pointerFile"
fi

printf '%s\n' "$pointer"
)}
# end module https://mdl.sh/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.2.sh
# start module https://mdl.sh/cache/cache-0.9.2.sh
cache() {(
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
# start module https://mdl.sh/printfq/printfq-0.9.1.sh
printfq() {(
# This module tries to replicate the sh_quote behaivor of `printf '%q ' "$@"` for data without new lines
# to offer a POSIX compliant alternative
# inspired by https://stackoverflow.com/questions/12162010/posix-sh-equivalent-for-bash-s-printf-q
case $# in 0) return 0; esac
while :
do
	# take a look at http://git.savannah.gnu.org/gitweb/?p=bash.git;a=blob;f=lib/sh/shquote.c#l337
	printf '%s' "$1" | sed -e 's/\([][ \t\r\\"|\&;()<>\!\{\}\*\?\^\$`'\'']\)/\\\1/g' -e 's/[^=:]~/\\~/g'
	shift
	# to exactly replicate the output of `printf '%q ' "$@"` we print the space before the break
	printf ' '
	case $# in 0) break; esac
done
printf '\n'
)}
# end module https://mdl.sh/printfq/printfq-0.9.1.sh

# Parameter default values
cacheDir="${cacheDir:-./cache}"
keyDict="false"
limitExists="false"
action="cache"
cmd=""

# Parameters
while : ; do
	#echo "processing an argument: $1"
	case "$1" in
	-d)
		cacheDir="$2"
		shift 2
		;;
	-k)
		keyDict="true"
		shift 1
		;;
	-r)
		action="reset"
		shift
		break
		;;
	-s)
		cmd="$2"
		shift 2
		break
		;;
	-t)
		timeLimit=$2
		limitExists="true"
		shift 2
		;;
	--)
		shift 1
		break
		;;
	-*)
		echo "Invalid argument $1"
		exit 1
		;;
	*)
		echo "Please use the -- argument terminator to avoid ambiguous arguments" >&2
		break
		;;
	esac
done

if [ "$action" = "reset" ]; then
	if [ -e "$cacheDir" ]; then
		rm -r "$cacheDir"
	fi
	return 0
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

if [ "$hit" = "false" ]; then
	#echo -n "executing: $cmd" >&2
	output="$(eval "$cmd")" && rc="$?" || rc="$?"
	#echo "return Value: $rc"
	if [ "$rc" = "0" ]; then
		if [ "$keyDict" = "true" ]; then
			echo "$cmd" > "$cacheDir/keyDict/$cacheKey"
		fi

		if [ "$(printf '%s' "$output" | wc -c)" = "0" ]; then
			printf '' > "$cacheFile"
		else
			printf '%s' "$output" > "$cacheFile"
		fi
	else
		return $rc
	fi
#else
#	echo "cache hit"
fi

cat "$cacheFile"
)}
# end module https://mdl.sh/cache/cache-0.9.2.sh
# start module https://mdl.sh/debug/debug-0.9.0.sh
debug() {(
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
envDebugSectionLevel="$(eval "printf '%s\\n' \"\${DEBUG_$section:-0}\"")"
if [ "$envDebugLevel" -ge "$level" ] || [ "$envDebugSectionLevel" -ge "$level" ]; then
	echo "$section: $msg" >&2
fi
)}
# end module https://mdl.sh/debug/debug-0.9.0.sh

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
)}
# end module https://mdl.sh/module/module-fetch-0.9.2.sh
# start module https://mdl.sh/module/module-scope-0.9.0.sh
moduleScope() {(
name="$1"
moduleContent="$2"

printf '%s() {(\n%s\n)}\n' "$name" "$moduleContent"
)}
# end module https://mdl.sh/module/module-scope-0.9.0.sh
# start module https://mdl.sh/module-tools/identifier-0.9.0.sh
identifier() {(
identifier="$1"

if [ "$(printf '%s' "$identifier" | head -c 5 | tr '[:upper:]' '[:lower:]')" = "https" ]; then
	## it seems to be an URL
	location="$identifier"
elif [ -f "$identifier" ]; then
	## it seems to be a path
	location="$identifier"
else
	## trying to transform the identifier to an URL
	if [ "${identifier#*/}" != "$identifier" ]; then
		# the identifier contains a slash
		location="https://mdl.sh/$identifier"
	else
		# no slash present within the identifier
		packageName="$(echo "$identifier" | sed -e 's;^\([^/]*\)-[^/-]*$;\1;' -e 's/-static$//' -e 's/-test$//')"
		location="https://mdl.sh/$packageName/$identifier"
	fi
	location="$(echo "$location" | sed 's;\([^:]\)//;\1/;g')"
fi

echo "$location"
)}
# end module https://mdl.sh/module-tools/identifier-0.9.0.sh

# transform identifier to location
location="$(identifier "$identifier")"

# obtain content from $location
if [ "$(printf '%s' "$location" | head -c 5 | tr '[:upper:]' '[:lower:]')" = "https" ]; then
	content="$(moduleFetch "$location")"
else
	content="$(cat "$location")"
fi

# wrap module
src="$(moduleScope "remoteExecution" "$content")"

# load module
eval "$src"

# remove the script as positional parameter
shift 1

# execute module
remoteExecution "$@"
