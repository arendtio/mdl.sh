#!/bin/sh

implementation="$1"
directory="$2"

module "timestamp" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-0.9.2.sh" "cksum-2374238394"

DEBUG_NAMESPACE="TIMESTAMP_SPEC"

# 1st january 2019
y2019="1546297200"
yearsSince2019="$(( $(date -u +"%Y") - 2019 ))"
debug "years since 2019: $yearsSince2019" TIMESTAMP_SPEC 2
secondsSince2019="$(( yearsSince2019 * 365 * 24 * 60 * 60))"
debug "seconds since 2019: $secondsSince2019" TIMESTAMP_SPEC 2
secondsCurrentYear="$(( $(date -u +"%j" | sed 's/^0*//') * 24 * 60 * 60 ))"
debug "seconds this year: $secondsCurrentYear" TIMESTAMP_SPEC 2
roughlyToday="$(( y2019 + secondsSince2019 + secondsCurrentYear))"

# +/- a day per year should be okay
tolerance="$(( (yearsSince2019 + 1) * 24 * 60 * 60))"
debug "Tolerance: $tolerance" TIMESTAMP_SPEC 2

stamp="$(timestamp)"

debug "Assert: $((roughlyToday - tolerance)) < $stamp < $((roughlyToday + tolerance))" TIMESTAMP_SPEC 1
if [ $stamp -lt $((roughlyToday - tolerance)) ] || [ $stamp -gt $((roughlyToday + tolerance)) ]; then
	error "'$stamp' is not within acceptable paramters ($((roughlyToday - tolerance)) < $stamp < $((roughlyToday + tolerance)))"
fi

