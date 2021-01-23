#!/bin/sh

implementation="$1"
directory="$2"

module "update" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.5.sh" "cksum-3256561424"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.22.sh" "cksum-1242620769"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_UPDATE_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="update"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="update 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# get assets
moduleFetch "https://mdl.sh/development/module/dependency/update/spec/assets/outdated-module-1.0.0.sh" > "$directory/outdated-module-1.0.0.sh"
moduleFetch "https://mdl.sh/development/module/dependency/update/spec/assets/mixed-quotes-and-whitespace-1.0.0.sh" > "$directory/mixed-quotes-and-whitespace-1.0.0.sh"
moduleFetch "https://mdl.sh/development/module/dependency/update/spec/assets/no-cksum-1.0.0.sh" > "$directory/no-cksum-1.0.0.sh"
moduleFetch "https://mdl.sh/development/module/dependency/update/spec/assets/non-existent-dependency-1.0.0.sh" > "$directory/non-existent-dependency-1.0.0.sh"
moduleFetch "https://mdl.sh/development/module/dependency/update/spec/assets/trailing-empty-line-1.0.0.sh" > "$directory/trailing-empty-line-1.0.0.sh"
moduleFetch "https://mdl.sh/development/module/dependency/update/spec/assets/variable-url-1.0.0.sh" > "$directory/variable-url-1.0.0.sh"

#
# Normal Tests
#
# simple test
update "$directory/outdated-module-1.0.0.sh"
target="902055318 116"
result="$(cksum <"$directory/outdated-module-1.0.1.sh")"
assertEqual "Update an outdated module" "$result" "$target"

# preserve quotes and whitespace
update "$directory/mixed-quotes-and-whitespace-1.0.0.sh"
target="1899188655 119"
result="$(cksum <"$directory/mixed-quotes-and-whitespace-1.0.1.sh")"
assertEqual "Preserve quote types and whitespace" "$result" "$target"

# preserve _optional_ checksum
update "$directory/no-cksum-1.0.0.sh"
target="2085977453 95"
result="$(cksum <"$directory/no-cksum-1.0.1.sh")"
assertEqual "Preserve optional checksum" "$result" "$target"

# non-existent dependency
target="1"
cmd="update '$directory/non-existent-dependency-1.0.0.sh'"
assertReturnCode "Non-existent dependency" "$target" "$cmd"

# trailing empty line
update "$directory/trailing-empty-line-1.0.0.sh"
target="2809447486 129"
result="$(cksum <"$directory/trailing-empty-line-1.0.1.sh")"
assertEqual "Update an outdated module" "$result" "$target"

# url from variable (ignore)
update "$directory/variable-url-1.0.0.sh"
target="$(cksum <"$directory/variable-url-1.0.0.sh")"
result="$(cksum <"$directory/variable-url-1.0.1.sh")"
assertEqual "Variable url" "$result" "$target"
