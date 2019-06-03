#!/bin/sh

implementation="$1"
directory="$2"

module "filterOld" "$implementation"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.6.sh" "cksum-2671631268"
module "assertReturnCode" "https://mdl.sh/spec-test/assert/return-code/assert-return-code-0.9.3.sh" "cksum-1471193511"
module "moduleFetch" "https://mdl.sh/module/fetch/module-fetch-0.9.18.sh" "cksum-2312336064"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_FILTER_SPEC"

#
# Error Tests
#
## No input
#target="66"
#cmd="filterOld"
#assertReturnCode "No input" "$target" "$cmd"

# Too many arguments
target="64"
cmd="filterOld 'one'"
assertReturnCode "Too many arguments" "$target" "$cmd"

#
# Normal Tests
#
# normal test
target="module/dependency/filter/spec/assets/nothing-1.0.1.sh"
result="$(printf 'module/dependency/filter/spec/assets/nothing-1.0.1.sh\nmodule/dependency/filter/spec/assets/nothing-1.0.0.sh\n' | filterOld)"
assertEqual "Normal" "$result" "$target"

# Bug: with this input the function resulted in no output at all,
# because findVersion didn't find the mdl.sh repository
export CONFIG_LOCAL_REPOSITORY="$directory"
baseUrl="https://mdl.sh/module/tools/dependency-update/spec/assets"
baseDir="$directory/mdl.sh"
mkdir "$baseDir"
moduleFetch "$baseUrl/module-a-1.0.0.sh" > "$baseDir/module-a-1.0.0.sh"
moduleFetch "$baseUrl/module-a-1.0.1.sh" > "$baseDir/module-a-1.0.1.sh"
moduleFetch "$baseUrl/module-b-1.0.0.sh" > "$baseDir/module-b-1.0.0.sh"

target="$(printf '%s\n' "mdl.sh/module-b-1.0.0.sh" "mdl.sh/module-a-1.0.1.sh")"
result="$(printf '%s\n' "mdl.sh/module-b-1.0.0.sh" "mdl.sh/module-a-1.0.1.sh" "mdl.sh/module-a-1.0.0.sh" | filterOld)"
assertEqual "Bug: No output" "$result" "$target"
unset CONFIG_LOCAL_REPOSITORY

