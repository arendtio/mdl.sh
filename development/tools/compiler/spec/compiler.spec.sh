#!/bin/sh

implementation="$1"
directory="$2"

module "compiler" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.22.sh" "cksum-1242620769"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"

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
	error "TEST: compiler does not return a non-zero value if the first argument does not exist"
fi

# result exists
touch "$directory/one.txt"
touch "$directory/two.txt"
if compiler "$directory/one.txt" "$directory/two.txt" >/dev/null 2>&1; then
	error "TEST: compiler does not return a non-zero value if the result file exists"
fi

# compile a basic file
printf '#!/bin/sh' >"$directory/one.txt"
rm "$directory/two.txt"
compiler "$directory/one.txt" "$directory/two.txt" >/dev/null
result="$(cat "$directory/two.txt")"
target="$(cat "$directory/one.txt")"
assertEqual "Compile empty file" "$result" "$target"


# compile-compiler-loop
codeFile="$directory/compiler.implementation.sh"
staticCompiler="$directory/compiler.static.sh"
secondCompiler="$directory/compiler2.static.sh"

debug "Fetch implementation and save it to a file" 1
moduleFetch "$implementation" >"$codeFile"

debug "Use the implementation to compile the fetched file" 1
compiler "$codeFile" "$staticCompiler" >/dev/null 2>&1

debug "Use the resulting static version of the compiler to compile the the fetched code again" 1
"$staticCompiler" "$codeFile" "$secondCompiler" >/dev/null 2>&1

debug "Ckeck if the result of the first compilation is equal to the second one" 1
result="$(cksum <"$secondCompiler")"
target="$(cksum <"$staticCompiler")"
assertEqual "Compiled compiler compiles" "$result" "$target"
