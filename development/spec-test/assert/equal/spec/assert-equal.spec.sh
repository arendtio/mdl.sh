#!/bin/sh

implementation="$1"
#directory="$2"

module "assertEqualImpl" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
#module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

# The debug module uses this variable
export DEBUG_NAMESPACE="ASSERT_EQUAL_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="assertEqualImpl"
assertReturnCode "No arguments" "$target" "$cmd"

# Too few arguments
target="64"
cmd="assertEqualImpl 'one' 'two'"
assertReturnCode "Too few arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="assertEqualImpl 'one' 'two' 'three' 'four' 'five'"
assertReturnCode "Too many arguments" "$target" "$cmd"

#
# Normal Tests
#
# normal test
target="0"
cmd="assertEqualImpl 'Description' '0' '0'"
assertReturnCode "Valid comparison" "$target" "$cmd"

# not equal
target="1"
cmd="assertEqualImpl 'Description' '0' '1'"
assertReturnCode "Invalid comparison" "$target" "$cmd"

# not equal text
target="1"
cmd="assertEqualImpl 'Description' 'A' 'B'"
assertReturnCode "Invalid text comparison" "$target" "$cmd"

# custom exit code
target="42"
cmd="assertEqualImpl 'Description' '0' '1' '42'"
assertReturnCode "Invalid comparison" "$target" "$cmd"

# custom exit code, but valid comparison
target="0"
cmd="assertEqualImpl 'Description' '0' '0' '42'"
assertReturnCode "Valid comparison" "$target" "$cmd"

