#!/bin/sh

# mandatory parameters
identifier="$1"
actualResult="$2"
validResult="$3"

# optional parameters
failCode="${4:-1}"

# dependencies
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"

debug "ASSERT: '$actualResult' = '$validResult'" 2 "${DEBUG_NAMESPACE:-ASSERT}"
if [ "$actualResult" != "$validResult" ]; then
	error "$(printf 'FAIL: "%s" test failed\nActual result: "%s"\nExpected result: "%s"\n' "$identifier" "$actualResult" "$validResult")" "$failCode"
fi
