#!/bin/sh
set -eu

if [ "$#" != "2" ]; then
	printf '2 arguments are required\n'
	exit 1
fi

if [ ! -f "$1" ]; then
	printf 'The input file does not exist. Aborting.\n'
	exit 1
fi

if [ -e "$2" ]; then
	printf 'The result file exists already. Aborting.\n'
	exit 1
fi

eval "$(curl -fsL "https://mdl.sh/latest")"
# start module https://mdl.sh/development/module/compiler/module-compiler-0.9.24.sh
moduleCompiler() { (
set -eu
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
# start module https://mdl.sh/development/module/fetch/module-fetch-0.9.21.sh
moduleFetch() { (
set -eu
# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
url="$1"

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
# start module https://mdl.sh/development/debug/debug-1.0.0.sh
debug() {
# guarantees: intentional-side-effects
# To understand this code please take a look at the README.md

if [ "$#" -gt 0 ] &&  [ "$(eval "printf '%s\\n' \"\${DEBUG_${3:-${DEBUG_NAMESPACE:-ALL}}:-$(printf '%s' "${DEBUG_ALL:-0}")}\"")" -ge "${2:-1}" ]; then
	printf '%s: %s\n' "${3:-${DEBUG_NAMESPACE:-ALL}}" "$1" >&2
fi
}
# end module https://mdl.sh/development/debug/debug-1.0.0.sh
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
) }
# end module https://mdl.sh/development/module/fetch/module-fetch-0.9.21.sh
# start module https://mdl.sh/development/module/scope/module-scope-0.9.4.sh
moduleScope() { (
set -eu
name="$1"
moduleContent="$2"

# awk: exit if the line does not start with a # otherwise {print $0}
moduleHeader="$(printf '%s\n' "$moduleContent" | awk '!/^#/ {exit}; {print $0}')"

if printf '%s\n' "$moduleHeader" | grep '^#[[:space:]]*guarantees:[[:space:]]*intentional-side-effects' >/dev/null 2>&1; then
	# no sub-shell, if the author promises to care about side-effects
	printf '%s() {\n%s\n}\n' "$name" "$moduleContent"
else
	# with sub-shell, default
	printf '%s() { (\nset -eu\n%s\n) }\n' "$name" "$moduleContent"
fi
) }
# end module https://mdl.sh/development/module/scope/module-scope-0.9.4.sh
# start module https://mdl.sh/development/module/validate/module-validate-0.9.8.sh
moduleValidate() { (
set -eu
# check number of arguments
if [ "$#" -ne 2 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
src="$1"
targetHash="$2"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
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

hashFunc="$(printf '%s' "$targetHash" | cut -d '-' -f1)"
srcHash="$(printf '%s' "$src" | moduleChecksum "$hashFunc")" || exit 65
if [ "$srcHash" != "$targetHash" ]; then
	exit 1
fi
) }
# end module https://mdl.sh/development/module/validate/module-validate-0.9.8.sh

compile() {
	srcString="$1"
	relativeBasePath="$2"

	# the pipe creates a sub-shell but that it not relevant here
	printf '%s' "$srcString" | while IFS="" read -r p || [ -n "$p" ]
	do
		# if we find a 'module "name" "url"' line
		moduleSyntaxRegex='^[[:space:]]*module\(Local\)*[[:space:]][^"'\'']*["'\'']\([^"'\'']*\)["'\''] ["'\'']\([^"'\'']*\)["'\''][[:space:]]*["'\'']*\([^"'\'']*\)["'\'']*$'
		if printf '%s\n' "$p" | grep "$moduleSyntaxRegex" >/dev/null; then
			func="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\2;")"
			url="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\3;")"
			checksum="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\4;")"
			scopeFlag="$(printf '%s\n' "$p" | sed 's;^[[:space:]]*module\(Local\)*[[:space:]]\{1,\}-s[[:space:]]\{1,\}.*$;true;')"

			printf 'processing %s\n' "$url" >&2

			#fetch and compile the target file
			printf '# start module %s\n' "$url"
			nextRelativeBase="/.." # a reasonable invalid path
			if [ "$(printf '%s' "$url" | head -c 8 | tr '[:upper:]' '[:lower:]')" = "https://" ]; then
				src="$(moduleFetch "$url")"
			elif [ "$(printf '%s' "$url" | head -c 1)" = "/" ]; then
				src="$(cat "$url")"
				nextRelativeBase="$(dirname "$url")"
			else
				src="$(cat "$relativeBasePath/$url")"
				nextRelativeBase="$(cd -P -- "$(dirname "$relativeBasePath/$url")" && pwd -P)"
			fi

			# validate checksum of src
			if [ "$checksum" != "" ]; then
				if ! moduleValidate "$src" "$checksum"; then
					error "Source code validation for $url failed. Exiting."
					exit 1
				fi
			fi

			# recursive call of this compiler
			src="$(compile "$src" "$nextRelativeBase")"
			# remove shebang and first empty line
			src="$(printf '%s' "$src" | awk '!f && /^#!\// {f=1;next}1' | awk '{if (NR==1 && NF==0) next};1')"

			# wrap module in a subshell
			if [ "$scopeFlag" = "true" ]; then
				printf '%s\n' "$src" # if -s is present
			else
				moduleScope "$func" "$src"
			fi
			printf '# end module %s\n' "$url"

		# if we find a "fetch modul.sh via curl line", remove it (the compiler should do what modul.sh does)
		elif printf '%s\n' "$p" | grep "^[[:space:]]*eval \"\$(curl -fsL [\"']https://[^\"']*/module/module-[^\"']*.sh[\"'])\"" >/dev/null; then
			printf ''
		elif printf '%s\n' "$p" | grep "^[[:space:]]*eval \".*/module-local/module-local-[^\"']*.sh.*\"" >/dev/null; then
			printf ''
		else
			printf '%s\n' "$p"
		fi
	done
}

compile "$@"
) }
# end module https://mdl.sh/development/module/compiler/module-compiler-0.9.24.sh

moduleCompiler "$(cat "$1")" "$(dirname "$1")" > "$2"
chmod +x "$2"
