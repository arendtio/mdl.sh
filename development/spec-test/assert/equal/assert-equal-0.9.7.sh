#!/bin/sh

# mandatory parameters
identifier="$1"
actualResult="$2"
validResult="$3"

# optional parameters
failCode="${4:-1}"

# dependencies
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"

debug "ASSERT: '$actualResult' = '$validResult'" 2 "${DEBUG_NAMESPACE:-ASSERT}"
if [ "$actualResult" != "$validResult" ]; then
	error "$(printf 'FAIL: "%s" test failed\nActual result: "%s"\nExpected result: "%s"\n' "$identifier" "$actualResult" "$validResult")" "$failCode"
fi
