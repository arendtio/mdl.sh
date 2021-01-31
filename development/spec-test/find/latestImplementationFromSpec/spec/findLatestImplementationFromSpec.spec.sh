#!/bin/sh

implementation="$1"
#directory="$2"

module "findLatestImplementationFromSpec" "$implementation"
#module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

# The debug module uses this variable
export DEBUG_NAMESPACE="FIND_LATEST_IMPLEMENTATION_FROM_SPEC_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="findLatestImplementationFromSpec"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="findLatestImplementationFromSpec 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# Invalid identifier
target="65"
cmd="findLatestImplementationFromSpec 'one'"
assertReturnCode "Invalid identifier" "$target" "$cmd"

# Not a spec
target="65"
cmd="findLatestImplementationFromSpec 'https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/simple/simple-0.0.0.sh'"
assertReturnCode "Identifier not a spec" "$target" "$cmd"

#
# Normal Tests
#
# normal test
target="https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/simple/simple-0.0.0.sh"
result="$(findLatestImplementationFromSpec "https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/simple/spec/simple.spec.sh")"
assertEqual "Simple test" "$result" "$target"

# find the newest version when there are other minor versions
target="https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/other-minor/other-minor-0.0.2.sh"
result="$(findLatestImplementationFromSpec "https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/other-minor/spec/other-minor.spec.sh")"
assertEqual "Other Minor Versions" "$result" "$target"

# find the correct version when there is a newer major version
target="https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/newer-major/newer-major-0.0.0.sh"
result="$(findLatestImplementationFromSpec "https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/newer-major/spec/newer-major-0.spec.sh")"
assertEqual "Newer Major Version" "$result" "$target"

# find the correct version when there is an older major version
target="https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/older-major/older-major-1.0.0.sh"
result="$(findLatestImplementationFromSpec "https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/older-major/spec/older-major-1.spec.sh")"
assertEqual "Older Major Version" "$result" "$target"

# find the correct version when there are other versions and the spec is for one specific version
target="https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/specific-version/specific-version-0.0.1.sh"
result="$(findLatestImplementationFromSpec "https://mdl.sh/development/spec-test/find/latestImplementationFromSpec/spec/assets/specific-version/spec/specific-version-0.0.1.spec.sh")"
assertEqual "Specific Version" "$result" "$target"

# TODO: Add a test, to fail if the repo is not available
