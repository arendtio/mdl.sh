#!/bin/sh

# mandatory parameters
identifier="$1"
actualResult="$2"
validResult="$3"

# optional parameters
failCode="${4:-1}"

# dependencies
module "error" "https://mdl.sh/error/error-1.0.2.sh" "cksum-2718151387"
module "debug" "https://mdl.sh/debug/debug-0.9.1.sh" "cksum-2534568300"

debug "ASSERT: '$actualResult' = '$validResult'" "${DEBUG_NAMESPACE:-ASSERT}" 2
if [ "$actualResult" != "$validResult" ]; then
	error "$(printf 'FAIL: "%s" test failed\nActual result: "%s"\nExpected result: "%s"\n' "$identifier" "$actualResult" "$validResult")" "$failCode"
fi
