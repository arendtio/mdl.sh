#!/bin/sh

implementation="$1"
#directory="$2"

module "compiler" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.22.sh" "cksum-1242620769"

# The debug module uses this variable
export DEBUG_NAMESPACE="COMPILER_SPEC"

# What does the compiler do?
# done - arguments (yes, but only one left)
# done - it replaces (add and remove) import statements with code + wrapper
# done	- how do import statements look like? (different forms)
# done 	- it does not recognize moduleLocal
# done - it fetches modules
# done - it adds the modulescope
# done - it works recursively
# done - it respects scope directives
# done - shebangs:
# done	- it removes shebangs (different versions?), except the first!
# done	- it re-uses/keeps the first shebang
# done - it fails if there is no shebang
# done - it removes the first empty line after the shebang
# done - it checks for hash-sums
# done - it removes module.sh init/bootstrap lines


#
# Error Tests
#
# No arguments
target="64"
cmd="compiler"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="compiler 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# Empty content
target="65"
cmd="compiler ''"
assertReturnCode "Empty content" "$target" "$cmd"

# No shebang
target="65"
cmd="$(printf 'compiler "\n"')"
assertReturnCode "No Shebang" "$target" "$cmd"

# Invalid hash
target="65"
cmd="compiler '$(moduleFetch "https://mdl.sh/development/module/compiler/spec/assets/invalid-hash-0.0.0.sh")'"
assertReturnCode "Invalid hash" "$target" "$cmd"


#
# Normal Tests
#
## Simple test
target="$(printf '#!/bin/bash\n' | cksum)"
input="$(printf '#!/bin/bash')"
result="$(compiler "$input" | cksum)"
assertEqual "Simple Module compile" "$result" "$target"

## Recursion
# we are testing multiple things here
# - module lines are being replaced with code
# - required modules are being fetched
# - the module scope is being added
baseUrl="https://mdl.sh/development/module/compiler/spec/assets/recursion"
input="$(moduleFetch "$baseUrl-0.0.0.sh")"
target="$(moduleFetch "$baseUrl-static-0.0.0.sh" | cksum)"
result="$(compiler "$input" | cksum)"
assertEqual "Recursive Module compile" "$result" "$target"

## Double recursion
# we are testing multiple things here
# - it works recursively
# - shebangs are being removed except the first
# - the first empty line after a removed shebang is being removed too
baseUrl="https://mdl.sh/development/module/compiler/spec/assets/recursion-recursion"
input="$(moduleFetch "$baseUrl-0.0.0.sh")"
target="$(moduleFetch "$baseUrl-static-0.0.0.sh" | cksum)"
result="$(compiler "$input" | cksum)"
assertEqual "Recursive Module compile with 2 Recursions" "$result" "$target"

# Test if the bootstrapping lines are being removed
baseUrl="https://mdl.sh/development/module/compiler/spec/assets/bootstrapping"
input="$(moduleFetch "$baseUrl-0.0.0.sh")"
target="$(moduleFetch "$baseUrl-static-0.0.0.sh" | cksum)"
result="$(compiler "$input" | cksum)"
assertEqual "Bootstrapping lines are being removed" "$result" "$target"

# Test if directives are being applied
baseUrl="https://mdl.sh/development/module/compiler/spec/assets/intentional-side-effect-use"
input="$(moduleFetch "$baseUrl-0.0.0.sh")"
target="$(moduleFetch "$baseUrl-static-0.0.0.sh" | cksum)"
result="$(compiler "$input" | cksum)"
assertEqual "directive intentional side effects is being applied" "$result" "$target"

# Test if shebangs are being re-used
baseUrl="https://mdl.sh/development/module/compiler/spec/assets/exotic-shebang"
input="$(moduleFetch "$baseUrl-0.0.0.sh")"
target="$(moduleFetch "$baseUrl-static-0.0.0.sh" | cksum)"
result="$(compiler "$input" | cksum)"
assertEqual "Shebang re-use" "$result" "$target"

# Module Lines
# Testing different versions of the module lines
testModuleLine() { (
	name="$1"
	baseUrl="https://mdl.sh/development/module/compiler/spec/assets/module-lines/$name"
	input="$(moduleFetch "$baseUrl-0.0.0.sh")"
	target="$(moduleFetch "$baseUrl-static-0.0.0.sh" | cksum)"
	result="$(compiler "$input" | cksum)"
	assertEqual "Module Line '$name'" "$result" "$target"
) }
testModuleLine "simple"
testModuleLine "simple-checksum"
testModuleLine "single"
testModuleLine "single-checksum"
testModuleLine "whitespace"
testModuleLine "missing-newline"

# ModuleLocal hast been removed and should not be handled
baseUrl="https://mdl.sh/development/module/compiler/spec/assets/module-lines/local"
input="$(moduleFetch "$baseUrl-0.0.0.sh")"
target="$(moduleFetch "$baseUrl-0.0.0.sh" | cksum)"
result="$(compiler "$input" | cksum)"
assertEqual "moduleLocal should not be handled" "$result" "$target"
