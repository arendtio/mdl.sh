#!/bin/sh

# mandatory parameters
identifier="$1"
actualResult="$2"
validResult="$3"

# optional parameters
failCode="${4:-1}"

# dependencies
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"

if [ "$actualResult" != "$validResult" ]; then
	error "$(printf 'FAIL: "%s" test failed\nActual result: "%s"\nExpected result: "%s"\n' "$identifier" "$actualResult" "$validResult")" "$failCode"
fi

