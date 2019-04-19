#!/bin/sh

implementation="$1"

module "moduleFetch" "$implementation"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.6.sh" "cksum-2671631268"
module "assertReturnCode" "https://mdl.sh/spec-test/assert/return-code/assert-return-code-0.9.3.sh" "cksum-1471193511"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_FETCH_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="moduleFetch"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="moduleFetch 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# Invalid URL windows
target="65"
cmd="moduleFetch 'C:\\Windows'"
assertReturnCode "Invalid URL Windows" "$target" "$cmd"

# Invalid URL http
target="65"
cmd="moduleFetch 'http://mdl.sh/latest'"
assertReturnCode "Invalid URL http" "$target" "$cmd"

# Unavailable URL
target="69"
cmd="moduleFetch 'https://localhost/thisdirdoesnotexist-unlessyoucreateditABCE'"
assertReturnCode "Unavailable URL" "$target" "$cmd"

# Invalid URL short-identifiert
target="65"
cmd="moduleFetch 'hello-world/hello-world-1.0.0.sh'"
assertReturnCode "Invalid URL short-identifier" "$target" "$cmd"

#
# Normal Tests
#
# normal test
# Note: we trim whitespaces; preserving them is not completely simple in a POSIX compliant way
target="1466632224 29"
result="$(moduleFetch "https://mdl.sh/hello-world/hello-world-1.0.0.sh" | cksum)"
assertEqual "Normal hello-world fetch" "$result" "$target"
