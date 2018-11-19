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
	echo "Please install md5sum (coreutils) or md5"
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
while : ; do
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
		break
	elif [ "$1" = "-t" ]; then
		timeLimit=$2
		limitExists="true"
		shift 2
	elif [ "$1" = "--" ]; then
		shift 1
		break
	elif [ "$(printf '%s' "$1" | cut -c 1)" = "-" ]; then
		echo "Invalid argument $1"
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
