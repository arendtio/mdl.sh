#!/bin/sh

implementation="$1"

module "moduleChecksum" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="MODULE_CHECKSUM_SPEC"

#
# Test errors
#
# omiting all arguments will block (as intended)

# too many arguments
target="64"
cmd="moduleChecksum 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# not existing hash command
target="69"
cmd="printf X | moduleChecksum 'neverEverHash'"
assertReturnCode "Non-existing hash command" "$target" "$cmd"

#
# Normal Tests
#
# empty content
result="$(printf '' | moduleChecksum)"
target="cksum-4294967295"
assertEqual "Empty content" "$result" "$target"

# just a newline
result="$(printf '\n' | moduleChecksum)"
target="cksum-3515105045"
assertEqual "One newline" "$result" "$target"

# two newlines
result="$(printf '\n\n' | moduleChecksum)"
target="cksum-3518178554"
assertEqual "Two newlines" "$result" "$target"

# two words
result="$(printf 'Foo Bar' | moduleChecksum)"
target="cksum-2520678754"
assertEqual "Two words" "$result" "$target"

# two lines
result="$(printf 'Foo\nBar\n'| moduleChecksum)"
target="cksum-214098449"
assertEqual "Two lines" "$result" "$target"

# custom hash command (function)
# just add Z as prefix and suffix
myHash() {
	printf 'Z%sZ' "$(cat -)"
}
result="$(printf 'abc' | moduleChecksum "myHash")"
target="myHash-ZabcZ"
assertEqual "Custom Hash function" "$result" "$target"

# First field of the hash
myHashWords() {
	printf 'A B C'
}
result="$(printf 'abc' | moduleChecksum "myHashWords")"
target="myHashWords-A"
assertEqual "Return only first word of hash" "$result" "$target"

# First field of the hash (tabs)
myHashTabWords() {
	printf 'A\tB\tC'
}
result="$(printf 'abc' | moduleChecksum "myHashTabWords")"
target="myHashTabWords-A"
assertEqual "Return only first word of hash (tabs)" "$result" "$target"
