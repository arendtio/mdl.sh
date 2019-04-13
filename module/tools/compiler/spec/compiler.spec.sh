#!/bin/sh

implementation="$1"
directory="$2"

module "compiler" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-0.9.2.sh" "cksum-2374238394"
module "moduleFetch" "https://mdl.sh/module/fetch/module-fetch-0.9.15.sh" "cksum-626475234"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.4.sh" "cksum-566303087"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="COMPILER_SPEC"

# not enough arguments
if compiler >/dev/null 2>&1; then
	error "TEST: compiler does not return a non-zero value if no arguments are supplied"
fi
if compiler "$directory/one.txt" >/dev/null 2>&1; then
	error "TEST: compiler does not return a non-zero value if too few arguments are supplied"
fi

# first argument does not exist
if compiler "$directory/one.txt" "$directory/two.txt" >/dev/null 2>&1; then
	error "TEST: compiler does not return a non-zero value if too few arguments are supplied"
fi

# result exists
touch "$directory/one.txt"
touch "$directory/two.txt"
if compiler "$directory/one.txt" "$directory/two.txt" >/dev/null 2>&1; then
	error "TEST: compiler does not return a non-zero value if the result file exists"
fi

# compile empty file
rm "$directory/two.txt"
compiler "$directory/one.txt" "$directory/two.txt" >/dev/null 2>&1
result="$(cat "$directory/two.txt")"
target=""
assertEqual "Compile empty file" "$result" "$target"


# compile-compiler-loop
codeFile="$directory/compiler.implementation.sh"
staticCompiler="$directory/compiler.static.sh"
secondCompiler="$directory/compiler2.static.sh"

debug "Fetch implementation and save it to a file" COMPILER_SPEC 1
moduleFetch "$implementation" >"$codeFile"

debug "Use the implmentation to compile the fetched file" COMPILER_SPEC 1
compiler "$codeFile" "$staticCompiler" >/dev/null 2>&1

debug "Use the resulting static version of the compiler to compile the the fetched code again" COMPILER_SPEC 1
"$staticCompiler" "$codeFile" "$secondCompiler" >/dev/null 2>&1

debug "Ckeck if the result of the first compilation is equal to the second one" COMPILER_SPEC 1
result="$(cksum <"$secondCompiler")"
target="$(cksum <"$staticCompiler")"
assertEqual "Compiled compiler compiles" "$result" "$target"
