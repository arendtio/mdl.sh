#!/bin/sh

implementation="$1"

module "timestamp" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="TIMESTAMP_SPEC"

# 1st january 2019
y2019="1546297200"
yearsSince2019="$(( $(date -u +"%Y") - 2019 ))"
debug "years since 2019: $yearsSince2019" 2
secondsSince2019="$(( yearsSince2019 * 365 * 24 * 60 * 60))"
debug "seconds since 2019: $secondsSince2019" 2
secondsCurrentYear="$(( $(date -u +"%j" | sed 's/^0*//') * 24 * 60 * 60 ))"
debug "seconds this year: $secondsCurrentYear" 2
roughlyToday="$(( y2019 + secondsSince2019 + secondsCurrentYear))"

# +/- a day per year should be okay
tolerance="$(( (yearsSince2019 + 1) * 24 * 60 * 60))"
debug "Tolerance: $tolerance" 2

stamp="$(timestamp)"

debug "Assert: $((roughlyToday - tolerance)) < $stamp < $((roughlyToday + tolerance))" 1
if [ "$stamp" -lt $((roughlyToday - tolerance)) ] || [ "$stamp" -gt $((roughlyToday + tolerance)) ]; then
	error "'$stamp' is not within acceptable paramters ($((roughlyToday - tolerance)) < $stamp < $((roughlyToday + tolerance)))"
fi

