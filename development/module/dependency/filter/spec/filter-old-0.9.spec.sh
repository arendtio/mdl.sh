#!/bin/sh

implementation="$1"
directory="$2"

module "filterOld" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.5.sh" "cksum-3256561424"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.22.sh" "cksum-1242620769"
module "moduleCompiler" "https://mdl.sh/development/module/compiler/module-compiler-1.0.0.sh" "cksum-3880525416"

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
target="development/module/dependency/filter/spec/assets/nothing-1.0.1.sh"
result="$(printf 'development/module/dependency/filter/spec/assets/nothing-1.0.1.sh\ndevelopment/module/dependency/filter/spec/assets/nothing-1.0.0.sh\n' | filterOld)"
assertEqual "Normal" "$result" "$target"

# Bug: with this input the function resulted in no output at all,
# because findVersion didn't find the mdl.sh repository
# still valid?
baseUrl="https://mdl.sh/development/tools/dependency-update/spec/assets"
baseDir="$directory/mdl.sh"
mkdir "$baseDir"
moduleFetch "$baseUrl/module-a-1.0.0.sh" > "$baseDir/module-a-1.0.0.sh"
moduleFetch "$baseUrl/module-a-1.0.1.sh" > "$baseDir/module-a-1.0.1.sh"
moduleFetch "$baseUrl/module-b-1.0.0.sh" > "$baseDir/module-b-1.0.0.sh"

# build a static version
debug "Starting compiler to create a static version of filter-old" 1
staticImplementation="$baseDir/filter-old-static.sh"
moduleCompiler "$(moduleFetch "$implementation")" > "$staticImplementation" 2>/dev/null
chmod +x "$staticImplementation"
debug "Finished compiling filter-old" 1

export CONFIG_LOCAL_REPOSITORY="$directory"
target="$(printf '%s\n' "mdl.sh/module-b-1.0.0.sh" "mdl.sh/module-a-1.0.1.sh")"
result="$(printf '%s\n' "mdl.sh/module-b-1.0.0.sh" "mdl.sh/module-a-1.0.1.sh" "mdl.sh/module-a-1.0.0.sh" | "$staticImplementation")"
unset CONFIG_LOCAL_REPOSITORY
assertEqual "Bug: No output" "$result" "$target"

