#!/bin/sh

implementation="$1"

module "benchmark" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-0.9.2.sh" "cksum-2374238394"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.5.sh" "cksum-566303087"

# shellcheck disable=SC2034  # Variable being used be debug module
DEBUG_NAMESPACE="BENCHMARK_SPEC"

moduleA="https://mdl.sh/module/benchmark/spec/assets/single-sleep-0.9.0.sh"
moduleB="https://mdl.sh/module/benchmark/spec/assets/double-sleep-0.9.0.sh"
moduleM="https://mdl.sh/module/benchmark/spec/assets/multiply-sleep-0.9.0.sh"
moduleArgs="2"

#
# negative tests
#

# too few arguments
result="0"
benchmark "Zero" >/dev/null 2>&1 || result="$?" && true
target="2"
assertEqual "Fail when less than 2 arguments are provided" "$result" "$target"

# non-existent module
result="0"
benchmark "$moduleA" "doesnotexist" >/dev/null 2>&1 || result="$?" && true
target="1"
assertEqual "Fail when one module does not exist" "$result" "$target"

#
# normal tests
#
# run a benchmark and save the output
output="$(benchmark "$moduleA" "$moduleB" $moduleArgs)"
debug "Benchmark output: $output" "$DEBUG_NAMESPACE" 1

# check for the header
result="$(printf '%s' "$output" | head -n 3)"
target="Calibrating... done

Starting benchmark with 2 rounds:"
assertEqual "Header check (incl. calibration)" "$result" "$target"

# check for moduleA benchmark output line
firstRun="$(printf '%s' "$output" | tail -n 3 | head -n 1)"
result="0"
printf '%s' "$firstRun" | grep "$moduleA completed 2 rounds in:" >/dev/null 2>&1 || result="$?" && true
target="0"
assertEqual "First benchmark line contains moduleA benchmark" "$result" "$target"

# check for moduleB benchmark output line
secondRun="$(printf '%s\n' "$output" | tail -n 2 | head -n 1)"
result="0"
printf '%s' "$secondRun" | grep "$moduleB completed 2 rounds in:" >/dev/null 2>&1 || result="$?" && true
target="0"
assertEqual "Second benchmark line contains moduleB benchmark" "$result" "$target"

## normal test
result="$(printf '%s\n' "$output" | tail -n 1)"
target="Lower is better."
assertEqual "Interpretation help" "$result" "$target"

# check if multiple arguments are getting passed correctly to the modules
# we use the multiply-sleep module here which should result in a sleep
# for 2 seconds
output="$(benchmark "$moduleM" "$moduleM" 2 1)"
debug "Benchmark output: $output" "$DEBUG_NAMESPACE" 1

# check the header for the calibration result
result="$(printf '%s' "$output" | head -n 3)"
target="Calibrating... done

Starting benchmark with 3 rounds:"
assertEqual "Multiple arguments are getting passed in" "$result" "$target"

