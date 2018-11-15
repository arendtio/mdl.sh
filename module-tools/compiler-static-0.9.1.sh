#!/bin/sh
set -eEuo pipefail

if [ "$#" != "2" ]; then
	echo "2 arguments are required"
	exit 1
fi

if [ -e "$2" ]; then
	echo "The result file exists already. Aborting."
	exit 1
fi

eval "$(curl -fsL "https://mdl.sh/latest")"
# start module https://mdl.sh/module/module-compiler-0.9.1.sh
moduleCompiler() {(
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
# start module https://mdl.sh/module/module-fetch-0.9.1.sh
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
# start module https://mdl.sh/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.1.sh
tmpDir() {(
# This module provides an easy way to create a tmp directory
# which can be found by other programs which use the same keyword.

# This module depends on mktemp
if ! command -v mktemp >/dev/null 2>&1; then
	return 1
fi

keyword="$1"

# Set directory to the same value every time this script gets invoked by the same user
# Note: This should work because in /tmp you can read only your own files

directory="${TMPDIR:-/tmp}"

# search pointer value
pointer="$(head -n1 $directory/"$keyword"-pointer* 2>/dev/null || true)"

# create, if it does not exist
if [ "$pointer" = "" ] || [ ! -d "$pointer" ]; then
	# remove old pointer
	rm -rf $directory/"$keyword"*
	# mktemp -t does not seem to be supported by the android version of mktemp
	# but is also not necessary
	if ! pointer="$(mktemp -p "$directory" -d "$keyword.XXXX")"; then
		printf 'mktemp -d "%s.XXXX" failed' "$keyword" >&2
		return $?
	fi
	if ! pointerFile="$(mktemp -p "$directory" "$keyword-pointer.XXXX")"; then
		printf 'mktemp "%s-pointer.XXXX" failed' "$keyword" >&2
		return $?
	fi
	echo "$pointer" >"$pointerFile"
fi

echo "$pointer"
)}
# end module https://mdl.sh/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.1.sh
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

url="$1"

# obtain the source code
# use the cache only if md5sum is available
executed="false"
if command -v md5sum >/dev/null 2>&1 || command -v md5 >/dev/null 2>&1; then
	# create/find the cache directory
	if cachePointer="$(tmpDir "module-cache")"; then
		# execute with cache
		src="$(cache -d "$cachePointer" -- httpsGet "$url")"
		executed="true"
	fi
fi

# if the command was not executed with the cache, we just skip the cache
if [ "$executed" == "false" ]; then
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
# end module https://mdl.sh/module/module-fetch-0.9.1.sh
# start module https://mdl.sh/module/module-scope-0.9.0.sh
moduleScope() {(
name="$1"
moduleContent="$2"

printf '%s() {(\n%s\n)}\n' "$name" "$moduleContent"
)}
# end module https://mdl.sh/module/module-scope-0.9.0.sh
# start module https://mdl.sh/module/module-validate-0.9.1.sh
moduleValidate() {(
src="$1"
targetHash="$2"

# start module https://mdl.sh/module/module-checksum-0.9.0.sh
moduleChecksum() {(
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

if ! command -v "$hashCmd" >/dev/null 2>&1; then
	error "Checksum command '$hashCmd' is not available. Exiting."
fi

printf '%s-' "$hashCmd"
printf '%s' "$content" | "$hashCmd" | cut -d ' ' -f1
printf '\n'
)}
# end module https://mdl.sh/module/module-checksum-0.9.0.sh

hashFunc="$(echo "$targetHash" | cut -d '-' -f1)"
srcHash="$(moduleChecksum "$src" "$hashFunc")"
if [ "$srcHash" != "$targetHash" ]; then
	return 1
fi
)}
# end module https://mdl.sh/module/module-validate-0.9.1.sh

compile() {
	srcString="$1"
	relativeBasePath="$2"

	# the pipe creates a sub-shell but that it not relevant here
	printf '%s' "$srcString" | while IFS="" read -r p || [ -n "$p" ]
	do
		# if we find a 'module "name" "url"' line
		moduleSyntaxRegex='^\s*module\(Local\)*\s[^"'\'']*["'\'']\([^"'\'']*\)["'\''] ["'\'']\([^"'\'']*\)["'\'']\s*["'\'']*\([^"'\'']*\)["'\'']*$'
		if printf '%s\n' "$p" | grep "$moduleSyntaxRegex" >/dev/null; then
			func="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\2;")"
			url="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\3;")"
			checksum="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\4;")"
			scopeFlag="$(printf '%s\n' "$p" | sed 's;^\s*module\(Local\)*\s\+-s\s\+.*$;true;')"

			echo "processing $url" >&2

			#fetch and compile the target file
			printf '# start module %s\n' "$url"
			nextRelativeBase="/.." # a reasonable invalid path
			if [ "$(printf '%s' "$url" | head -c 5 | tr '[:upper:]' '[:lower:]')" = "https" ]; then
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
		elif printf '%s\n' "$p" | grep "^\\s*eval \"\$(curl -fsL [\"']https://[^\"']*/module/module-[^\"']*.sh[\"'])\"" >/dev/null; then
			printf ''
		elif printf '%s\n' "$p" | grep "^\\s*eval \".*/module-local/module-local-[^\"']*.sh.*\"" >/dev/null; then
			printf ''
		else
			printf '%s\n' "$p"
		fi
	done
}

compile "$@"
)}
# end module https://mdl.sh/module/module-compiler-0.9.1.sh

moduleCompiler "$(cat "$1")" "$(dirname "$1")" > "$2"
chmod +x "$2"
