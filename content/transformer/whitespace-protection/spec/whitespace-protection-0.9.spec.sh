#!/bin/sh

implementation="$1"
#directory="$2"

module "whitespaceProtection" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

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

# begin & end tests
target="AAA A "
result="$(whitespaceProtection begin; printf ' A ')"
assertEqual "Add whitespace protection to the start" "$result" "$target"

target=" A ZZZ"
result="$(printf ' A '; whitespaceProtection end)"
assertEqual "Add whitespace protection to the end" "$result" "$target"

target="AAA A ZZZ"
result="$(whitespaceProtection begin; printf ' A '; whitespaceProtection end)"
assertEqual "Add whitespace protection via begin and end" "$result" "$target"

target="$(printf ' A ' | cksum)"
result="$(printf '%s' "$(whitespaceProtection begin; printf ' A '; whitespaceProtection end)" | whitespaceProtection remove | cksum)"
assertEqual "Add whitespace protection via begin and end and remove it again via remove" "$result" "$target"

