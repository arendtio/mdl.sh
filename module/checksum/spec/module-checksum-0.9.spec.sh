#!/bin/sh

implementation="$1"

module "moduleChecksum" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-0.9.2.sh" "cksum-2374238394"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.4.sh" "cksum-566303087"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="MODULE_CHECKSUM_SPEC"

#
# Test errors
#
# omit arguments
target="64"
result="0"
moduleChecksum >/dev/null 2>&1 || result="$?" && true
assertEqual "No arguments" "$result" "$target"

# too many arguments
target="64"
result="0"
moduleChecksum "one" "two" "three">/dev/null 2>&1 || result="$?" && true
assertEqual "Too many arguments" "$result" "$target"

# not existing hash command
target="69"
result="0"
moduleChecksum "one" "neverEverHash">/dev/null 2>&1 || result="$?" && true
assertEqual "Non-Existing hash command" "$result" "$target"

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
myHash(){
	printf 'Z%sZ' "$(cat -)"
}
result="$(moduleChecksum "abc" "myHash")"
target="myHash-ZabcZ"
assertEqual "Custom Hash function" "$result" "$target"
