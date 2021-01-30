#!/bin/sh

implementation="$1"
#directory="$2"

module "remote" "$implementation"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

# The debug module uses this variable
export DEBUG_NAMESPACE="REMOTE_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="remote"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="remote 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

#
# Normal Tests
#
# normal test
target="simple"
result="$(remote "https://mdl.sh/development/tools/remote/spec/assets/simple-0.0.0.sh")"
assertEqual "Simplest test" "$result" "$target"

# test if module.sh is available
target="simple"
result="$(remote "https://mdl.sh/development/tools/remote/spec/assets/second-level-0.0.0.sh")"
assertEqual "Module.sh availability test" "$result" "$target"

# test for short identifiers
target="simple"
result="$(remote "development/tools/remote/spec/assets/simple-0.0.0.sh")"
assertEqual "Short identifier test" "$result" "$target"

# test for passing return code
target="42"
cmd="remote 'https://mdl.sh/development/tools/remote/spec/assets/return-code-0.0.0.sh'"
assertReturnCode "Return code passing test" "$target" "$cmd"

