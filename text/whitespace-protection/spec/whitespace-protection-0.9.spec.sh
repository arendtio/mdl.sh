#!/bin/sh

implementation="$1"
#directory="$2"

module "whitespaceProtection" "$implementation"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.6.sh" "cksum-2671631268"
module "assertReturnCode" "https://mdl.sh/spec-test/assert/return-code/assert-return-code-0.9.3.sh" "cksum-1471193511"

# The debug module uses this variable
export DEBUG_NAMESPACE="WHITESPACE_PROTECTION_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="whitespaceProtection"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="whitespaceProtection 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# Invalid argument
target="64"
cmd="whitespaceProtection 'one'"
assertReturnCode "Invalid argument" "$target" "$cmd"

#
# Normal Tests
#
target="AAA A ZZZ"
result="$(printf ' A ' | whitespaceProtection add)"
assertEqual "Add whitespace protection" "$result" "$target"

target="$(printf ' A ' | cksum)"
result="$(printf 'AAA A ZZZ' | whitespaceProtection remove | cksum)"
assertEqual "Remove whitespace protection" "$result" "$target"

target="$(printf '\n Here \n\t we\t\ngo\t \n\n' | hexdump -C)"
result="$(printf '\n Here \n\t we\t\ngo\t \n\n' | whitespaceProtection add | whitespaceProtection remove | hexdump -C)"
assertEqual "Mixed input-output" "$result" "$target"

target="$(printf 'AAAZZZ' | cksum)"
result="$(printf 'AAAAAAZZZZZZ' | whitespaceProtection remove | cksum)"
assertEqual "Tricky content" "$result" "$target"

target="$(printf 'HelloWorld!\n' | cksum)"
result="$(printf 'AAAHelloWorld!\nZZZ' | whitespaceProtection remove | cksum)"
assertEqual "String with newline" "$result" "$target"

