#!/bin/sh

implementation="$1"

module "hello" "$implementation"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.1.sh" "cksum-2022066480"

assertEqual "Simple string" "$(hello)" "Hello World"
assertEqual "Static cksum" "$(hello | cksum)" "2146730865 12"
assertEqual "Dynamic cksum" "$(hello | cksum)" "$(printf 'Hello World\n' | cksum)"