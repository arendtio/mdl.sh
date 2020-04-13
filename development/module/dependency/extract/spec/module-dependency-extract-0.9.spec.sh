#!/bin/sh

implementation="$1"
directory="$2"

module "moduleDependencyExtract" "$implementation"

module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.21.sh" "cksum-2848792046"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_EXTRACT_SPEC"

#
# Error Tests
#
# Too many arguments
target="64"
cmd="moduleDependencyExtract 'one'"
assertReturnCode "Too many arguments" "$target" "$cmd"

#
# Normal Tests
#
moduleFetch "https://mdl.sh/development/module/dependency/extract/spec/assets/dependencies-1.0.0.sh" >"$directory/dependencies-1.0.0.sh"

# normal test
target="$(printf 'https://mdl.sh/normal-1.0.0.sh
https://mdl.sh/plain-1.0.0.sh
https://mdl.sh/single-1.0.0.sh
https://mdl.sh/mixed-1.0.0.sh
https://mdl.sh/spaces-1.0.0.sh
https://mdl.sh/spaces2-1.0.0.sh
https://mdl.sh/tabs-1.0.0.sh
https://mdl.sh/tabs2-1.0.0.sh
https://mdl.sh/path/path-1.0.0.sh
https://mdl.sh/path/path2/path2-1.0.0.sh
https://mdl.sh/no-ckecksum-1.0.0.sh
https://example.com/nonmdl-1.0.0.sh')"
result="$(moduleDependencyExtract <"$directory/dependencies-1.0.0.sh")"
assertEqual "Normal test" "$result" "$target"

