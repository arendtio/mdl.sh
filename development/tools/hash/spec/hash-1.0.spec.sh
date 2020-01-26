#!/bin/sh

implementation="$1"

module "hash" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

# The debug module uses this variable
export DEBUG_NAMESPACE="HASH_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="hash"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="hash 'one' 'two' 'three'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# Invalid identifier
target="65"
cmd="hash 'one'"
assertReturnCode "Invalid identifier" "$target" "$cmd"

# Non-script file
target="65"
cmd="hash 'https://mdl.sh/module/fetch/spec/assets/abc.txt'"
assertReturnCode "Non-script file" "$target" "$cmd"

# non-existent hash function
target="69"
cmd="hash 'https://mdl.sh/hello-world/hello-world-1.0.1.sh' 'unavailableHashFunction'"
assertReturnCode "Unavailable hash function" "$target" "$cmd"

#
# Normal Tests
#
# Output length
target="13"
result="$(hash "https://mdl.sh/hello-world/hello-world-1.0.1.sh" | wc -l)"
assertEqual "Output length" "$result" "$target"

# last line
target='module "helloWorld" "https://mdl.sh/hello-world/hello-world-1.0.1.sh" "cksum-3769348439"'
result="$(hash "https://mdl.sh/hello-world/hello-world-1.0.1.sh" | tail -n 1)"
assertEqual "Last line" "$result" "$target"

# short identifier
target='module "helloWorld" "https://mdl.sh/hello-world/hello-world-1.0.1.sh" "cksum-3769348439"'
result="$(hash "hello-world-1.0.1.sh" | tail -n 1)"
assertEqual "Short identifier" "$result" "$target"

# custom hash function
customHash(){
	# wc -l does not count lines without a newline character at the end and module-fetch trims whitespaces
	printf 'A%sZ' "$(cat - | wc -l)"
}
target='module "helloWorld" "https://mdl.sh/hello-world/hello-world-1.0.1.sh" "customHash-A4Z"'
result="$(hash "hello-world-1.0.1.sh" "customHash" | tail -n 1)"
assertEqual "Custom hash function" "$result" "$target"


