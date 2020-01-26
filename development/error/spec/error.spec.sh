#!/bin/sh

implementation="$1"
#directory="$2"

module "errImpl" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"

# default return value does not exist
result=""
(errImpl "No real error 1" >/dev/null 2>&1) || result="$?" && true
target="1"
assertEqual "Default return code" "$result" "$target"

# stderr output
result="$(errImpl "No real error 2" 2>&1 >/dev/null)" || true
target="No real error 2"
assertEqual "Stderr output" "$result" "$target"

# nothing to stdout
result="$(errImpl "No real error 3" 2>/dev/null)" || true
target=""
assertEqual "No output to stdout" "$result" "$target"

# custom return value
(errImpl "No real error 4" 42 >/dev/null 2>&1) || result="$?" && true
target="42"
assertEqual "Custom return code" "$result" "$target"
