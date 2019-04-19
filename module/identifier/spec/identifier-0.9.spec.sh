#!/bin/sh

implementation="$1"
directory="$2"

module "identifier" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.6.sh" "cksum-2671631268"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="IDENTIFIER_SPEC"

# no argument
result="0"
identifier >/dev/null 2>&1 || result="$?" && true
target="1"
assertEqual "Fail on no argument" "$result" "$target"

# too many arguments
result="0"
identifier "A" "B">/dev/null 2>&1 || result="$?" && true
target="1"
assertEqual "Fail on too many arguments" "$result" "$target"

# basic url test
result="$(identifier "https://mdl.sh/hello-world/hello-world-1.0.0.sh")"
target="https://mdl.sh/hello-world/hello-world-1.0.0.sh"
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
result="$(identifier "my-short/url-module-1.0.0.sh")"
target="https://mdl.sh/my-short/url-module-1.0.0.sh"
assertEqual "Half URL" "$result" "$target"

# long half url test
result="$(identifier "my/long/url-module-1.0.0.sh")"
target="https://mdl.sh/my/long/url-module-1.0.0.sh"
assertEqual "Long half URL" "$result" "$target"

# pure package name test
result="$(identifier "hello-world-1.0.0.sh")"
target="https://mdl.sh/hello-world/hello-world-1.0.0.sh"
assertEqual "Pure package name" "$result" "$target"

# package name starting with https
result="$(identifier "https-get/spec/https-get-1.0.spec.sh")"
target="https://mdl.sh/https-get/spec/https-get-1.0.spec.sh"
assertEqual "Pure package name" "$result" "$target"
