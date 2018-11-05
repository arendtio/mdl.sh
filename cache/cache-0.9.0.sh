#!/bin/sh
# Make is easy to cache the result of a command
# Example:
# cache -- curl -sL "https://mdl.sh"
# cache -- curl -sL "https://mdl.sh"
# For the first line this modul executes curl, stores the result in the cache folder and writes the result to stdout
# for the second command it just reads the result from the cache folder and writes it to stdout
# The cache uses the md5 hash of the command as a key to identify similar commands

##  Check for Dependencies (md5sum ist actually part of the coreutils, but not POSIX)
if ! command -v md5sum >/dev/null 2>&1 ; then
	echo "Please install md5sum (coreutils?)"
	exit 1
fi

# for POSIX compatibility
module "printfq" "https://mdl.sh/printfq/printfq-0.9.0.sh" "cksum-2815862747"

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
		echo "Please use the -- argument terminator to avoid ambiguous arguments"
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

cacheKey="$(echo "$cmd" | md5sum | cut -d" " -f1)"
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
	#echo -n "executing: $cmd" > /dev/stderr
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
