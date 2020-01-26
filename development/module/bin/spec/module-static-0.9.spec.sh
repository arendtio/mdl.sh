#!/bin/sh

implementation="$1"

module "moduleBin" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.21.sh" "cksum-2848792046"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_BIN_SPEC"

#
# Error Code Tests
#

# check if rc=1 on $# != 1: no arguments
target="1"
result="0"
moduleBin >/dev/null 2>&1 || result="$?" && true
assertEqual "No arguments" "$result" "$target"

# check if rc=1 on $# != 1: multiple arguments
target="1"
result="0"
moduleBin "one" "two" >/dev/null 2>&1 || result="$?" && true
assertEqual "Multiple arguments" "$result" "$target"

# check if rc=1 on $1 != init
target="1"
result="0"
moduleBin "one" >/dev/null 2>&1 || result="$?" && true
assertEqual "One arguments, but not 'init'" "$result" "$target"

#
# Normal Tests
#

# check if the output matches the output of the "online" module
lines="500"
coreUrl="$(printf '%s' "$implementation" | sed 's;mdl.sh/development/module/bin/;mdl.sh/development/module/online/;')"
debug "Core URL '$coreUrl'" 1
coreCksum="$(moduleFetch "$coreUrl" | tail -n "$lines" | cksum)"

# compare the cksum of the last "$lines" lines
result="$(moduleBin init | tail -n "$lines" | cksum)"
target="$coreCksum"
assertEqual "Test description" "$result" "$target"

