#!/bin/sh

implementation="$1"

module "moduleBin" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-0.9.2.sh" "cksum-2374238394"
module "moduleFetch" "https://mdl.sh/module/module-fetch-0.9.14.sh" "cksum-626475234"
module "moduleScope" "https://mdl.sh/module/module-scope-0.9.2.sh" "cksum-424520902"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.4.sh" "cksum-566303087"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="MODULE_BIN_SPEC"

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
coreUrl="$(printf '%s' "$implementation" | sed 's;mdl.sh/module/bin/;mdl.sh/module/online/;')"
debug "Core URL '$coreUrl'" "$DEBUG_NAMESPACE" 1
coreCode="$(moduleFetch "$coreUrl")"
coreCksum="$(printf '%s\n' "$coreCode" | tail -n "$lines" | cksum)"

# compare the cksum of the last "$lines" lines
result="$(moduleBin init | tail -n "$lines" | cksum)"
target="$coreCksum"
assertEqual "Test describtion" "$result" "$target"

