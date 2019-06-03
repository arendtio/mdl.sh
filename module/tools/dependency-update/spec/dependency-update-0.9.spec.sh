#!/bin/sh

implementation="$1"
directory="$2"

module "dependencyUpdate" "$implementation"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.6.sh" "cksum-2671631268"
module "assertReturnCode" "https://mdl.sh/spec-test/assert/return-code/assert-return-code-0.9.3.sh" "cksum-1471193511"
module "moduleFetch" "https://mdl.sh/module/fetch/module-fetch-0.9.20.sh" "cksum-78205726"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_UPDATE_TOOL_SPEC"

# fetch assets (needs to be done before we set CONFIG_LOCAL_REPOSITORY)
baseUrl="https://mdl.sh/module/tools/dependency-update/spec/assets"
baseDir="$directory/mdl.sh"
mkdir "$baseDir"
moduleFetch "$baseUrl/module-a-1.0.0.sh" > "$baseDir/module-a-1.0.0.sh"
moduleFetch "$baseUrl/module-a-1.0.1.sh" > "$baseDir/module-a-1.0.1.sh"
moduleFetch "$baseUrl/module-b-1.0.0.sh" > "$baseDir/module-b-1.0.0.sh"

# make dependency update use the directory as a repository
export CONFIG_LOCAL_REPOSITORY="$directory"

#
# Error Tests
#
# No arguments
target="0"
cmd="dependencyUpdate"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="dependencyUpdate 'one' 'two' 'three' 'four'"
assertReturnCode "Too many arguments" "$target" "$cmd"

#
# Normal Tests
#
# Confirmation Test "No"
target="3"
dependencyUpdate "no" >/dev/null
# shellcheck disable=SC2012
result="$(ls "$baseDir" | wc -l)"
assertEqual "Not writing new files if first parameter is 'no'" "$result" "$target"

# Confirmation Test "Yes"
target="4"
dependencyUpdate "yes"
# shellcheck disable=SC2012
result="$(ls "$baseDir" | wc -l)"
assertEqual "Writing new files if first parameter is 'Yes'" "$result" "$target"
# Content Test
target="1080050300 83"
result="$(cksum <"$baseDir/module-b-1.0.1.sh")"
assertEqual "Content of the updated module" "$result" "$target"
rm "$baseDir/module-b-1.0.1.sh"

# Scan Pattern Test
mkdir -p "$baseDir/module-c"
cp "$baseDir/module-b-1.0.0.sh" "$baseDir/module-c/module-c-1.0.0.sh"
dependencyUpdate yes mdl.sh 'module-c-*.*.sh'
target="true"
result="false"
[ -f "$baseDir/module-c/module-c-1.0.1.sh" ] && [ ! -f "$baseDir/module-b-1.0.1.sh" ] && result="true"
assertEqual "Scan pattern" "$result" "$target"
rm "$baseDir/module-c/module-c-1.0.1.sh"

# Scan Offset Test
dependencyUpdate yes mdl.sh/module-c
target="true"
result="false"
[ -f "$baseDir/module-c/module-c-1.0.1.sh" ] && [ ! -f "$baseDir/module-b-1.0.1.sh" ] && result="true"
assertEqual "Scan offset" "$result" "$target"
rm "$baseDir/module-c/module-c-1.0.1.sh"

mkdir -p "$directory/example.com/module-d"
cp "$baseDir/module-b-1.0.0.sh" "$directory/example.com/module-d/module-d-1.0.0.sh"

## Scan Host Offset Test
# TODO: fails due to findVersion being mdl.sh specific...
#dependencyUpdate yes example.com
#target="true"
#result="false"
#[ -f "$directory/example.com/module-d/module-d-1.0.1.sh" ] && [ ! -f "$baseDir/module-b-1.0.1.sh" ] && result="true"
#assertEqual "Scan host offset" "$result" "$target"
#rm "$directory/example.com/module-d/module-d-1.0.1.sh"

# Scan Default Offset Test
dependencyUpdate yes
target="true"
result="false"
[ -f "$baseDir/module-b-1.0.1.sh" ] && [ ! -f "$directory/example.com/module-d/module-d-1.0.1.sh" ] && result="true"
assertEqual "Default scan offset" "$result" "$target"

