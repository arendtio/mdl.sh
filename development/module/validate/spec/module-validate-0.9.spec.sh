#!/bin/sh

implementation="$1"

module "moduleValidate" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_VALIDATE_SPEC"

#
# Error Tests
#
target="64"
cmd="moduleValidate"
assertReturnCode "No arguments" "$target" "$cmd"

target="64"
cmd="moduleValidate 'one' 'two' 'three'"
assertReturnCode "Too many arguments" "$target" "$cmd"

target="65"
cmd="moduleValidate 'one' 'malformedHash'"
assertReturnCode "Malformed hash" "$target" "$cmd"

#
# Normal Tests
#
target="0"
cmd="moduleValidate 'one' 'cksum-2648632822'"
assertReturnCode "Matching hash for simple string" "$target" "$cmd"

target="1"
cmd="moduleValidate 'one' 'cksum-111'"
assertReturnCode "Invalid  hash for simple string" "$target" "$cmd"

target=""
result="$(moduleValidate 'one' 'cksum-2648632822')"
assertEqual "Empty output if cksum matches" "$result" "$target"

target="0"
withNewline="$(printf 'one\nX')"
cmd="moduleValidate '${withNewline%X}' 'cksum-815791956'"
assertReturnCode "With newline at the end" "$target" "$cmd"

# custom hash function
myHash() {
	printf '%s' "$(( $(cat -) + 100 ))"
}
target="0"
cmd="moduleValidate '23' 'myHash-123'"
assertReturnCode "Custom hash function" "$target" "$cmd"

