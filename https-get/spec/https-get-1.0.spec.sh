#!/bin/sh

implementation="$1"

module "httpsGet" "$implementation"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.6.sh" "cksum-2671631268"
module "assertReturnCode" "https://mdl.sh/spec-test/assert/return-code/assert-return-code-0.9.3.sh" "cksum-1471193511"

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
target="1346054948 31"
result="$(httpsGet "https://mdl.sh/hello-world/hello-world-1.0.0.sh" | cksum)"
assertEqual "Basic hello-world fetch" "$result" "$target"

# Unavailable URL
target="69"
cmd="httpsGet 'https://localhost/thisdirdoesnotexist-unlessyoucreateditABCE'"
assertReturnCode "Unavailable URL" "$target" "$cmd"

