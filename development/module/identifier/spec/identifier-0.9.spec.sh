#!/bin/sh

implementation="$1"
directory="$2"

module "identifier" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.5.sh" "cksum-3256561424"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="IDENTIFIER_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="identifier"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="identifier 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# Invalid identifier
target="65"
cmd="identifier 'one'"
assertReturnCode "Invalid identifier" "$target" "$cmd"

#
# Normal Tests
#
# basic url test
target="https://mdl.sh/hello-world/hello-world-1.0.0.sh"
result="$(identifier "https://mdl.sh/hello-world/hello-world-1.0.0.sh")"
assertEqual "Basic URL" "$result" "$target"

# Path to existing file
#
# NOTE: This test was changed. An ealier version required to output the
# unchanged path to existing files. This however caused some inconsistent
# behaviour as module-fetch does not implement the same logic and explicitly
# should not support fetching local files unless a local repository is
# configured.
(
	cd "$directory" || exit 1
	file="category/my-test-module-1.0.0.sh"
	mkdir "$(dirname "$file")"
	touch "$file"
	target="https://mdl.sh/$file"
	result="$(identifier "$file")"
	assertEqual "Path to existing file" "$result" "$target"
)

# half url test
target="https://mdl.sh/my-short/url-module-1.0.0.sh"
result="$(identifier "my-short/url-module-1.0.0.sh")"
assertEqual "Half URL" "$result" "$target"

# long half url test
target="https://mdl.sh/my/long/url-module-1.0.0.sh"
result="$(identifier "my/long/url-module-1.0.0.sh")"
assertEqual "Long half URL" "$result" "$target"

# pure package name test
target="https://mdl.sh/hello-world/hello-world-1.0.0.sh"
result="$(identifier "hello-world-1.0.0.sh")"
assertEqual "Pure package name" "$result" "$target"

# package name starting with https (bugfix)
target="https://mdl.sh/https-get/spec/https-get-1.0.spec.sh"
result="$(identifier "https-get/spec/https-get-1.0.spec.sh")"
assertEqual "Pure package name" "$result" "$target"

# spec for all versions (bugfix)
target="https://mdl.sh/https-get/spec/https-get.spec.sh"
result="$(identifier "https-get/spec/https-get.spec.sh")"
assertEqual "Spec for all versions" "$result" "$target"
