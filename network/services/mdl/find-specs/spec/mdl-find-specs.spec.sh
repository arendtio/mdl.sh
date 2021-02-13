#!/bin/sh

implementation="$1"
#directory="$2"

module "mdlFindSpecs" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

# The debug module uses this variable
export DEBUG_NAMESPACE="MDL_FIND_SPECS_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="mdlFindSpecs"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="mdlFindSpecs 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

#
# Normal Tests
#
assetsPath="https://mdl.sh/network/services/mdl/find-specs/spec/assets"
# normal test
target="$assetsPath/simple/spec/simple.spec.sh"
result="$(mdlFindSpecs "/network/services/mdl/find-specs/spec/assets/simple")"
assertEqual "Simple" "$result" "$target"

# do not descend lower than spec folders
target="$assetsPath/descend/spec/descend.spec.sh"
result="$(mdlFindSpecs "/network/services/mdl/find-specs/spec/assets/descend")"
assertEqual "Descend not lower than first spec folder" "$result" "$target"

# with the initial argument it is possible to jump into asset folders
target="$assetsPath/descend/spec/descend2/spec/descend2.spec.sh"
result="$(mdlFindSpecs "/network/services/mdl/find-specs/spec/assets/descend/spec")"
assertEqual "Jump into a spec folder via the initial argument" "$result" "$target"

# find multiple modules
target="$(printf \
'%s/multi-module/one/spec/one.spec.sh
%s/multi-module/two/spec/two.spec.sh' "$assetsPath" "$assetsPath")"
result="$(mdlFindSpecs "/network/services/mdl/find-specs/spec/assets/multi-module")"
assertEqual "Find specs for multiple modules" "$result" "$target"

# find multiple versions of a spec
target="$(printf \
'%s/versions/spec/versions-0.spec.sh
%s/versions/spec/versions-1.0.spec.sh
%s/versions/spec/versions-1.1.spec.sh
%s/versions/spec/versions-2.spec.sh' "$assetsPath" "$assetsPath" "$assetsPath" "$assetsPath")"
result="$(mdlFindSpecs "/network/services/mdl/find-specs/spec/assets/versions")"
assertEqual "Find specs for multiple modules" "$result" "$target"

