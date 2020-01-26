#!/bin/sh

implementation="$1"

module "moduleFetch" "$implementation"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

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
cmd="moduleFetch 'misc/hello-world/hello-world-1.0.1.sh'"
assertReturnCode "Invalid URL short-identifier" "$target" "$cmd"

# Fetch a non-script file
target="65"
cmd="moduleFetch 'https://mdl.sh/development/module/fetch/spec/assets/abc.txt'"
assertReturnCode "Non-script file" "$target" "$cmd"

#
# Normal Tests
#
# normal test
# NOTE: we do not trim whitespace anymore
target="3769348439 35"
result="$(moduleFetch "https://mdl.sh/misc/hello-world/hello-world-1.0.1.sh" | cksum)"
assertEqual "Normal hello-world fetch" "$result" "$target"
