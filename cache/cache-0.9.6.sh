#!/bin/sh
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
module "printfq" "https://mdl.sh/printfq/printfq-0.9.3.sh" "cksum-2698230364"

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
