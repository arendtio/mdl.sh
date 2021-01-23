#!/bin/sh

implementation="$1"

module "assertReturnCode" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="ASSERT_RETURN_CODE_SPEC"

#
# Error Tests
#
## No arguments
target="64"
result="0"
assertReturnCode >/dev/null 2>&1 || result="$?" && true
assertEqual "No arguments" "$result" "$target"

## Too many arguments
target="64"
result="0"
assertReturnCode "One" "Two" "Three" "Four" >/dev/null 2>&1 || result="$?" && true
assertEqual "Too many arguments" "$result" "$target"

## Empty first arguments
target="1"
result="0"
assertReturnCode "" "1" "ls">/dev/null 2>&1 || result="$?" && true
assertEqual "Empty first argument" "$result" "$target"

#
# Normal Tests
#
# just return 0 if rc matches the expected rc is fine
# expect rc = 0
target="0"
result="0"
assertReturnCode "example descrition" "0" "sh -c 'exit 0;'" >/dev/null 2>&1 || result="$?" && true
assertEqual "Return code zero if command returns zero as expected" "$result" "$target"

# expect rc = 1
target="0"
result="0"
assertReturnCode "example descrition" "1" "sh -c 'exit 1;'" >/dev/null 2>&1 || result="$?" && true
assertEqual "Return code zero if command returns zero as expected" "$result" "$target"

# return 1 if expectations are not matched
# expect rc = 0
target="1"
result="0"
assertReturnCode "example descrition" "0" "sh -c 'exit 1;'" >/dev/null 2>&1 || result="$?" && true
assertEqual "Return code one if command returns one but should not" "$result" "$target"

# expect rc = 1
target="1"
result="0"
assertReturnCode "example descrition" "1" "sh -c 'exit 0;'" >/dev/null 2>&1 || result="$?" && true
assertEqual "Return code one if command returns zero but should not" "$result" "$target"

# use a custom function within the cmd
retOne() {
	return 1;
}
target="0"
result="0"
#assertReturnCode "example descrition" "1" "retOne" >/dev/null 2>&1 || result="$?" && true
assertReturnCode "example descrition" "1" "retOne" || result="$?" && true
assertEqual "Custom function" "$result" "$target"

# contermination test
# use a function that is imported by this module but not by the executed code;
# 'debug' in this case
target="0"
result="0"
assertReturnCode "example description" "127" "debug 'nothing'" >/dev/null 2>&1 || result="$?" && true
assertEqual "Contermination tests" "$result" "$target"

