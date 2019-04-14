#!/bin/sh

implementation="$1"

module "moduleModule" "$implementation"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.5.sh" "cksum-566303087"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="MODULE_SPEC"

runModuleTests() { (
	modulesh="$1"

	#
	# Negative Tests
	#

	# fail if not possible (e.g. fetch fails)
	target="69"
	result="0"
	"$modulesh" "noFunc" "doesnotexist" >/dev/null 2>&1 || result="$?" && true
	assertEqual "Module does not exist" "$result" "$target"

	# invalid function name (e.g. '-s')
	# POSIX: a word consisting solely of underscores, digits, and alphabetics from the portable character set. The first character of a name is not a digit.
	# Protable characterset: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap06.html#tag_06_01
	target="65"
	result="0"
	"$modulesh" -s "https://mdl.sh/hello-world/hello-world-1.0.1.sh" >/dev/null 2>&1 || result="$?" && true
	assertEqual "Invalid function name" "$result" "$target"

	# invalid checksum
	target="65"
	result="0"
	"$modulesh" "helloWorld" "https://mdl.sh/hello-world/hello-world-1.0.1.sh" "invalid-checksum" >/dev/null 2>&1 || result="$?" && true
	assertEqual "Invalid checksum" "$result" "$target"

	#
	# Normal Tests
	#

	# unlikely to exist
	funcName="fooAbcdeF"

	# check if the function exists
	target="1"
	result="0"
	command -v "$funcName" >/dev/null 2>&1 || result="$?" && true
	assertEqual "Test precondition 1 function does not exist" "$result" "$target"

	# run modulesh
	# create a function
	# - with the name $funcName
	"$modulesh" "$funcName" "https://mdl.sh/hello-world/hello-world-1.0.1.sh" "cksum-4087673976"

	# check if the function exists
	target="0"
	result="0"
	command -v "$funcName" >/dev/null 2>&1 || result="$?" && true
	assertEqual "Test if function was created" "$result" "$target"

	# check function output
	target="$(printf 'Hello World\n' | cksum)"
	result="$("$funcName" | cksum)"
	assertEqual "Test output of the created function" "$result" "$target"

	# check if a broken checksum prevents the function creation
	funcName="fooAbcdefG"

	# check if the function exists
	target="1"
	result="0"
	command -v "$funcName" >/dev/null 2>&1 || result="$?" && true
	assertEqual "Test precondition 2 function does not exist" "$result" "$target"

	# run modulesh with a BROKEN checksum
	target="65"
	result="0"
	"$modulesh" "$funcName" "https://mdl.sh/hello-world/hello-world-1.0.1.sh" "cksum-4087673975" >/dev/null 2>&1 || result="$?" && true
	assertEqual "Test function creation with invalid checksum" "$result" "$target"

	# check if the function exists
	target="1"
	result="0"
	command -v "$funcName" >/dev/null 2>&1 || result="$?" && true
	assertEqual "Test if function was NOT created" "$result" "$target"

	# check if the scoping works
	target=""
	assertEqual "Test precondition 3 if variable 'myVar' is set" "${myVar:-}" "$target"

	funcName="varFunc"
	"$modulesh" "$funcName" "https://mdl.sh/module/core/spec/assets/variable-0.9.0.sh" "cksum-1670937996"
	# execute the module to set the variable
	"$funcName"
	target=""
	assertEqual "Test check if the scope prevented the variable from being set" "${myVar:-}" "$target"
) }

runModuleTests "moduleModule"

