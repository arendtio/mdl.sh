#!/bin/sh

implementation="$1"
directory="$2"

module "debug" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.2.sh" "cksum-1669532880"

# ouput to stderr
result="$(DEBUG_ALL=1 debug "One" 2>&1 1>/dev/null)"
target="ALL: One"
assertEqual "Output to stderr" "$result" "$target"

# no output to stdout
result="$(DEBUG_ALL=1 debug "One" 2>/dev/null)"
target=""
assertEqual "No output to stdout" "$result" "$target"

# silence, DEBUG_ALL=undefined
result="$(debug "One" ALL 1 2>&1)"
target=""
assertEqual "Silence" "$result" "$target"

# section SPECIFIC
result="$(DEBUG_SPECIFIC=1 debug "One" SPECIFIC 2>&1 1>/dev/null)"
target="SPECIFIC: One"
assertEqual "Section SPECIFIC" "$result" "$target"

# section with underscore
result="$(DEBUG_SPECIFIC_UNDERSCORE=1 debug "One" SPECIFIC_UNDERSCORE 2>&1 1>/dev/null)"
target="SPECIFIC_UNDERSCORE: One"
assertEqual "Section with underscore" "$result" "$target"

# level tests
# ALL=0
result="$(DEBUG_ALL=0 debug "One" SPECIFIC 1 2>&1)"
target=""
assertEqual "Section ALL with level 0" "$result" "$target"

# print always
result="$(debug "One" SPECIFIC 0 2>&1)"
target="SPECIFIC: One"
assertEqual "Print always (level 0)" "$result" "$target"

# ALL=1
result="$(DEBUG_ALL=1 debug "One" SPECIFIC 1 2>&1)"
target="SPECIFIC: One"
assertEqual "Section ALL with level 1" "$result" "$target"

# ALL=1, but required level 2
result="$(DEBUG_ALL=1 debug "One" SPECIFIC 2 2>&1)"
target=""
assertEqual "Section ALL=1, but required level 2" "$result" "$target"

# ALL=2
result="$(DEBUG_ALL=2 debug "One" SPECIFIC 1 2>&1)"
target="SPECIFIC: One"
assertEqual "Section ALL with level 2" "$result" "$target"

# ALL=undefined, SPECIFIC=2
result="$(DEBUG_SPECIFIC=2 debug "One" SPECIFIC 1 2>&1)"
target="SPECIFIC: One"
assertEqual "ALL=undefined, SPECIFIC=2" "$result" "$target"

# ALL=0, SPECIFIC=2
result="$(DEBUG_ALL=0 DEBUG_SPECIFIC=2 debug "One" SPECIFIC 1 2>&1)"
target="SPECIFIC: One"
assertEqual "ALL=undefined, SPECIFIC=2" "$result" "$target"

# ALL=1, SPECIFIC=0
result="$(DEBUG_ALL=1 DEBUG_SPECIFIC=0 debug "One" SPECIFIC 1 2>&1)"
target=""
assertEqual "ALL=undefined, SPECIFIC=2" "$result" "$target"


# BUG: Fix Debug: DEBUG_ALL=5 doesn't seem to set DEBUG_FETCH for example
target="FETCH: One"
result="$(DEBUG_ALL=5 debug "One" "FETCH" "5" 2>&1 1>/dev/null)"
assertEqual "Bug: DEBUG_ALL=5 for DEBUG_FETCH=5" "$result" "$target"
