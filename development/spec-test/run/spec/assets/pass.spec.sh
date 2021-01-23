#!/bin/sh

implementation="$1"

module "simple" "$implementation"
module "assertReturnCode" "https://mdl.sh/development/spec-test/assert/return-code/assert-return-code-0.9.4.sh" "cksum-1582104248"

target="1"
cmd="simple 1"
assertReturnCode "Return one" "$target" "$cmd"
