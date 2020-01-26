#!/bin/sh

implementation="$1"
directory="$2"

module "dependencyUpdate" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.21.sh" "cksum-2848792046"
module "moduleCompiler" "https://mdl.sh/development/module/compiler/module-compiler-0.9.26.sh" "cksum-1678143937"
# we require the static ASSERT versions, because they are run while the local repository is set to the test repo
# that way it works completely offline
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-static-0.9.7.sh" "cksum-1063031039"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-static-0.9.4.sh" "cksum-1792781022"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_UPDATE_TOOL_SPEC"

# fetch assets (needs to be done before we set CONFIG_LOCAL_REPOSITORY)
baseUrl="https://mdl.sh/development/tools/dependency-update/spec/assets"
baseDir="$directory/mdl.sh"
mkdir "$baseDir"
moduleFetch "$baseUrl/module-a-1.0.0.sh" > "$baseDir/module-a-1.0.0.sh"
moduleFetch "$baseUrl/module-a-1.0.1.sh" > "$baseDir/module-a-1.0.1.sh"
moduleFetch "$baseUrl/module-b-1.0.0.sh" > "$baseDir/module-b-1.0.0.sh"

# create a static version of the $implementation to let it work offline too
debug "Starting compiler to create a static version of dependency-update" 1
staticImplementation="$directory/dependency-update-static.sh"
moduleCompiler "$(moduleFetch "$implementation")" "$(dirname "$baseDir")" > "$staticImplementation" 2>/dev/null
chmod +x "$staticImplementation"
debug "Finished compiling dependency-update" 1

# set local repository to test repository
export CONFIG_LOCAL_REPOSITORY="$directory"

#
# Error Tests
#
# No arguments
target="0"
# make dependency update use the directory as a repository
cmd="'$staticImplementation'"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="'$staticImplementation' 'one' 'two' 'three' 'four'"
assertReturnCode "Too many arguments" "$target" "$cmd"

#
# Normal Tests
#
# Confirmation Test "No"
target="3"
"$staticImplementation" "no" >/dev/null
# shellcheck disable=SC2012
result="$(ls "$baseDir" | wc -l)"
assertEqual "Not writing new files if first parameter is 'no'" "$result" "$target"

# Confirmation Test "Yes"
debug "Before update $(ls "$baseDir")" 1
target="4"
"$staticImplementation" "yes"
# shellcheck disable=SC2012
result="$(ls "$baseDir" | wc -l)"
debug "After update with write access $(ls "$baseDir")" 1
assertEqual "Writing new files if first parameter is 'yes'" "$result" "$target"
# Content Test
target="3210451901 81"
result="$(cksum <"$baseDir/module-b-1.0.1.sh")"
assertEqual "Content of the updated module" "$result" "$target"
rm "$baseDir/module-b-1.0.1.sh"

# Scan Pattern Test
mkdir -p "$baseDir/module-c"
cp "$baseDir/module-b-1.0.0.sh" "$baseDir/module-c/module-c-1.0.0.sh"
"$staticImplementation" yes mdl.sh 'module-c-*.*.sh'
target="true"
result="false"
[ -f "$baseDir/module-c/module-c-1.0.1.sh" ] && [ ! -f "$baseDir/module-b-1.0.1.sh" ] && result="true"
assertEqual "Scan pattern" "$result" "$target"
rm "$baseDir/module-c/module-c-1.0.1.sh"

# Scan Offset Test
"$staticImplementation" yes mdl.sh/module-c
target="true"
result="false"
[ -f "$baseDir/module-c/module-c-1.0.1.sh" ] && [ ! -f "$baseDir/module-b-1.0.1.sh" ] && result="true"
assertEqual "Scan offset" "$result" "$target"
rm "$baseDir/module-c/module-c-1.0.1.sh"

mkdir -p "$directory/example.com/module-d"
cp "$baseDir/module-b-1.0.0.sh" "$directory/example.com/module-d/module-d-1.0.0.sh"

## Scan Host Offset Test
# TODO: fails due to findVersion being mdl.sh specific...
#"$staticImplementation" yes example.com
#target="true"
#result="false"
#[ -f "$directory/example.com/module-d/module-d-1.0.1.sh" ] && [ ! -f "$baseDir/module-b-1.0.1.sh" ] && result="true"
#assertEqual "Scan host offset" "$result" "$target"
#rm "$directory/example.com/module-d/module-d-1.0.1.sh"

# Scan Default Offset Test
"$staticImplementation" yes
target="true"
result="false"
[ -f "$baseDir/module-b-1.0.1.sh" ] && [ ! -f "$directory/example.com/module-d/module-d-1.0.1.sh" ] && result="true"
assertEqual "Default scan offset" "$result" "$target"

unset CONFIG_LOCAL_REPOSITORY
