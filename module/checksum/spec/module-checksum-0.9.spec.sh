#!/bin/sh

implementation="$1"

module "moduleChecksum" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.5.sh" "cksum-566303087"
module "assertReturnCode" "https://mdl.sh/spec-test/assert/return-code/assert-return-code-0.9.1.sh" "cksum-4255239761"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="MODULE_CHECKSUM_SPEC"

#
# Test errors
#
# omit arguments
target="64"
cmd="moduleChecksum"
assertReturnCode "No arguments" "$target" "$cmd"

# too many arguments
target="64"
cmd="moduleChecksum 'one' 'two' 'three'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# not existing hash command
target="69"
cmd="moduleChecksum 'one' 'neverEverHash'"
assertReturnCode "Non-existing hash command" "$target" "$cmd"

#
# Normal Tests
#
# empty content
result="$(moduleChecksum "")"
target="cksum-4294967295"
assertEqual "Empty content" "$result" "$target"

# just a newline
input="$(printf '\nX')"
result="$(moduleChecksum "${input%X}")"
target="cksum-3515105045"
assertEqual "One newline" "$result" "$target"

# two newlines
input="$(printf '\n\nX')"
result="$(moduleChecksum "${input%X}")"
target="cksum-3518178554"
assertEqual "Two newlines" "$result" "$target"

# two words
result="$(moduleChecksum "Foo Bar")"
target="cksum-2520678754"
assertEqual "Two words" "$result" "$target"

# two lines
input="$(printf 'Foo\nBar\nX')"
result="$(moduleChecksum "${input%X}")"
target="cksum-214098449"
assertEqual "Two lines" "$result" "$target"

# custom hash command (function)
# just add Z as prefix and suffix
myHash() {
	printf 'Z%sZ' "$(cat -)"
}
result="$(moduleChecksum "abc" "myHash")"
target="myHash-ZabcZ"
assertEqual "Custom Hash function" "$result" "$target"

# First field of the hash
myHashWords() {
	printf 'A B C'
}
result="$(moduleChecksum "abc" "myHashWords")"
target="myHashWords-A"
assertEqual "Return only first word of hash" "$result" "$target"

# First field of the hash (tabs)
myHashTabWords() {
	printf 'A\tB\tC'
}
result="$(moduleChecksum "abc" "myHashTabWords")"
target="myHashTabWords-A"
assertEqual "Return only first word of hash (tabs)" "$result" "$target"

