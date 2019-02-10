#!/bin/sh

implementation="$1"
directory="$2"

module "errImpl" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.4.sh" "cksum-566303087"

# file does not exist
if errImpl "No real Error" >/dev/null 2>&1; then
	error "TEST: Error does not return a non-zero return code" 1
fi

# stderr output
result="$(errImpl "No real error" 2>&1 >/dev/null || true)"
target="No real error"
assertEqual "Stderr output" "$result" "$target"

# nothing to stdout
result="$(errImpl "No real error" 2>/dev/null || true)"
target=""
assertEqual "No output to stdout" "$result" "$target"

# custom return value
errImpl "No real Error" 42 >/dev/null 2>&1 || result="$?" && true
target="42"
assertEqual "Custom return code" "$result" "$target"
