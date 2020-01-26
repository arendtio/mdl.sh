#!/bin/sh
# usage example: module-benchmark-0.9.0.sh https://mdl.sh/debug/debug-0.9.1.sh https://mdl.sh/debug/debug-1.0.0.sh "debug message"
set -eu

if [ "$#" -lt 2 ]; then
	printf 'At least two arguments are required (module URLs)\n'
	exit 2
fi

# mandatory parameters
modA="$1" # 1
shift 1
modB="$1" # 2
shift 1

# dependencies
module "timestamp" "https://mdl.sh/development/polyfill/POSIX/timestamp/timestamp-0.9.1.sh" "cksum-1916476112"

module "funcA" "$modA" || exit 1
module "funcB" "$modB" || exit 1

# find out how many rounds a function can do within ~3 seconds (+ 1 round)
timeout="3"
calibrate(){
	count="0"
	startTime="$(timestamp)"
	# run the module for about $timeout seconds (more or less)
	while [ "$(( $(timestamp) - startTime ))" -lt "$timeout" ]; do
		count="$(( count + 1 ))"
		( "$@" >/dev/null 2>&1 ) || true
	done
	printf '%s' "$count"
}

runBenchmark() {
	i=0
	while [ "$i" -lt "$limit" ]; do
		( "$@" >/dev/null 2>&1 ) || true
		i="$(( i + 1 ))"
	done
}

measure() {
	printf '%s completed %s rounds in: ' "$1" "$limit"
	shift 1
	{
		time "$@";
	} 2>&1 | awk '/^real/{print $2}'
}

printf 'Calibrating... '
aLimit="$(calibrate funcA "$@")"
bLimit="$(calibrate funcB "$@")"
limit="$(( (aLimit + bLimit) / 2 + 1 ))"
printf 'done\n\n'

printf 'Starting benchmark with %s rounds:\n' "$limit"
measure "$modA" runBenchmark funcA "$@"
measure "$modB" runBenchmark funcB "$@"
printf 'Lower is better.\n'
