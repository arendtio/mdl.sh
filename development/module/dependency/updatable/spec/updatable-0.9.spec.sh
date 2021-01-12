#!/bin/sh

implementation="$1"
#directory="$2"

module "updatable" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.22.sh" "cksum-1242620769"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_UPDATABLE_SPEC"

# CONCEPT:
# - input is a path to a file
# - the module lines contain URLs, so we have to convert the URLs to paths somehow...

#
# Error Tests
#
# No arguments
target="64"
cmd="updatable"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="updatable 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# preparing assets
dirUrl="https://mdl.sh/development/module/dependency/updatable/spec/assets"
#moduleFetch "$dirUrl/updateable-by-version-1.0.0.sh" > "$directory/updateable-by-version-1.0.0.sh"
#moduleFetch "$dirUrl/updateable-by-version-1.0.1.sh" > "$directory/updateable-by-version-1.0.1.sh"
#moduleFetch "$dirUrl/updateable-by-outdated-reference-1.0.0.sh" > "$directory/updateable-by-outdated-reference-1.0.0.sh"
#moduleFetch "$dirUrl/updateable-by-recursion-1.0.0.sh" > "$directory/updateable-by-recursion-1.0.0.sh"

#
# Normal Tests
#
# USE-CASES:
# - a dependency has a newer version (outdated reference)
# - a dependency can be updated (recursion)

# outdated reference
target="$(printf '%s\n' "$dirUrl/updateable-by-outdated-reference-1.0.0.sh")"
result="$(updatable "$dirUrl/updateable-by-outdated-reference-1.0.0.sh")"
assertEqual "Outdated by reference" "$result" "$target"

# recursion
target="$(printf '%s\n' "$dirUrl/updateable-by-outdated-reference-1.0.0.sh" "$dirUrl/updateable-by-recursion-1.0.0.sh")"
result="$(updatable "$dirUrl/updateable-by-recursion-1.0.0.sh")"
assertEqual "Outdated by recursion" "$result" "$target"

# TODO: add a spec case
