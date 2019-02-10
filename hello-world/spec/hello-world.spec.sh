#!/bin/sh

implementation="$1"

module "hello" "$implementation"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.3.sh" "cksum-3344728351"

assertEqual "Simple string" "$(hello)" "Hello World"
assertEqual "Static cksum" "$(hello | cksum)" "2146730865 12"
assertEqual "Dynamic cksum" "$(hello | cksum)" "$(printf 'Hello World\n' | cksum)"
