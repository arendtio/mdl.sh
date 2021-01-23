#!/bin/sh

implementation="$1"
#directory="$2"

module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.5.sh" "cksum-3256561424"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.22.sh" "cksum-1242620769"
module "moduleCompiler" "https://mdl.sh/development/module/compiler/module-compiler-1.0.0.sh" "cksum-3880525416"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_ONLINE_SPEC"

runModuleTests() { (
	# get the implementation, compile it
	src="$(moduleCompiler "$(moduleFetch "$implementation")")"

	# precondition
	unset -f module

	# execute the src
	eval "$src"

	# check if a function module was created
	assertReturnCode "Test if a function 'module' was created" "0" "command -v 'module' >/dev/null 2>&1"

	# check if the function module can create functions from modules
	module "abc" "https://mdl.sh/development/module/online/spec/assets/abc-0.0.0.sh" "cksum-3237326754"

	# check if a new function was created by the module call
	assertReturnCode "Test if a function 'abc' was created" "0" "command -v 'abc' >/dev/null 2>&1"

	# Test the created function
	target="ABC"
	result="$(abc)"
	assertEqual "Test the created function" "$result" "$target"
) }

runModuleTests "moduleModule"

