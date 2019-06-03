#!/bin/sh

implementation="$1"
#directory="$2"

module "updatable" "$implementation"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.6.sh" "cksum-2671631268"
module "assertReturnCode" "https://mdl.sh/spec-test/assert/return-code/assert-return-code-0.9.3.sh" "cksum-1471193511"
module "moduleFetch" "https://mdl.sh/module/fetch/module-fetch-0.9.18.sh" "cksum-2312336064"

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
dirUrl="https://mdl.sh/module/dependency/updatable/spec/assets"
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
