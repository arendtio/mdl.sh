#!/bin/sh

implementation="$1"

module "httpsGet" "$implementation"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

# The debug module uses this variable
export DEBUG_NAMESPACE="HTTPS_GET_SPEC"

#
# Error Tests
#
# No arguments
target="64"
cmd="httpsGet"
assertReturnCode "No arguments" "$target" "$cmd"

# Too many arguments
target="64"
cmd="httpsGet 'one' 'two'"
assertReturnCode "Too many arguments" "$target" "$cmd"

# Non-https URL
target="65"
cmd="httpsGet 'http://mdl.sh/latest'"
assertReturnCode "Non-HTTPS URL" "$target" "$cmd"

#
# Normal Tests
#
## normal test
target="3769348439 35"
result="$(httpsGet "https://mdl.sh/misc/hello-world/hello-world-1.0.1.sh" | cksum)"
assertEqual "Basic hello-world fetch" "$result" "$target"

# Unavailable URL
target="69"
cmd="httpsGet 'https://localhost/thisdirdoesnotexist-unlessyoucreateditABCE'"
assertReturnCode "Unavailable URL" "$target" "$cmd"

