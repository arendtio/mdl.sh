#!/bin/sh

implementation="$1"

module "hello" "$implementation"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"

assertEqual "Simple string" "$(hello)" "Hello World"
assertEqual "Static cksum" "$(hello | cksum)" "2146730865 12"
assertEqual "Dynamic cksum" "$(hello | cksum)" "$(printf 'Hello World\n' | cksum)"
