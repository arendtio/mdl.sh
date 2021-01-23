#!/bin/sh

implementation="$1"
#directory="$2"

module "specTestRun" "$implementation"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.5.sh" "cksum-3256561424"

# The debug module uses this variable
export DEBUG_NAMESPACE="SPEC_TEST_RUN_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="specTestRun"
assertReturnCode "No arguments" "$target" "$cmd"

# Too few arguments
target="64"
cmd="specTestRun 'one'"
assertReturnCode "Too few arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="specTestRun 'one' 'two' 'three'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# invalid identifier spec
target="1"
cmd="specTestRun 'pass.spec.sh' 'development/spec-test/run/spec/assets/simple-0.0.0.sh'"
assertReturnCode "Invalid identifier spec" "$target" "$cmd"

# invalid identifier implementation
target="1"
cmd="specTestRun 'development/spec-test/run/spec/assets/pass.spec.sh' 'simple.sh'"
assertReturnCode "Invalid identifier implementation" "$target" "$cmd"

#
# PASS Tests
#
# PASS output test
target=""
result="$(specTestRun "development/spec-test/run/spec/assets/pass.spec.sh" "development/spec-test/run/spec/assets/simple-0.0.0.sh")"
assertEqual "PASS Output Test" "$result" "$target"

# PASS output test with stderr
# NOTE: fails if debug is enabled, because it writes to stderr too
target=""
result="$(specTestRun "development/spec-test/run/spec/assets/pass.spec.sh" "development/spec-test/run/spec/assets/simple-0.0.0.sh" 2>&1)"
assertEqual "PASS Output Test with STDERR" "$result" "$target"

# PASS Return Code
target="0"
cmd="specTestRun 'development/spec-test/run/spec/assets/pass.spec.sh' 'development/spec-test/run/spec/assets/simple-0.0.0.sh'"
assertReturnCode "PASS return code" "$target" "$cmd"

#
# FAIL Tests
#
(
	set +e
	# FAIL output test
	target=""
	result="$(specTestRun "development/spec-test/run/spec/assets/fail.spec.sh" "development/spec-test/run/spec/assets/simple-0.0.0.sh" 2>/dev/null)"
	assertEqual "FAIL Output Test" "$result" "$target"

	# FAIL output test with stderr
	target="4108881047 82"
	result="$(specTestRun "development/spec-test/run/spec/assets/fail.spec.sh" "development/spec-test/run/spec/assets/simple-0.0.0.sh" 2>&1 | cksum)"
	assertEqual "FAIL Output Test with STDERR" "$result" "$target"

	# FAIL return code
	target="1"
	cmd="specTestRun 'development/spec-test/run/spec/assets/fail.spec.sh' 'development/spec-test/run/spec/assets/simple-0.0.0.sh'"
	assertReturnCode "FAIL return code" "$target" "$cmd"
)

# Empty test directory test
target="0"
cmd='specTestRun "development/spec-test/run/spec/assets/empty-dir.spec.sh" "development/spec-test/run/spec/assets/simple-0.0.0.sh"'
assertReturnCode "Test for empty test directory" "$target" "$cmd"

# Debug module not imported
target="127"
cmd='specTestRun "development/spec-test/run/spec/assets/missing-dep.spec.sh" "development/spec-test/run/spec/assets/simple-0.0.0.sh"'
assertReturnCode "Missing debug module dependency test" "$target" "$cmd"

# Completly undefined command
target="127"
cmd='specTestRun "development/spec-test/run/spec/assets/undefined-cmd.spec.sh" "development/spec-test/run/spec/assets/simple-0.0.0.sh"'
assertReturnCode "Undefined command test" "$target" "$cmd"

