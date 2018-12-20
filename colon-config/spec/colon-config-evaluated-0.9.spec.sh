#!/bin/sh

implementation="$1"
directory="$2"

module "colonConfig" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.1.sh" "cksum-2022066480"

# This can be used to debug print all asserts with
# DEBUG_COLON_CONFIG_SPEC=2 ./run-all.sh
# mind the DEBUG_ before the namespace
DEBUG_NAMESPACE="COLON_CONFIG_SPEC"

# create config files
printf 'One: A\nTwo: $X\nThree: $X/and $Y/\nFour: $Z\nFive: ~\n' >$directory/first.conf
X="myX"
Y="myY"
Z="my little space train"

# normal value
result="$(colonConfig "One" "$directory/first.conf" "default")"
target="A"
assertEqual "Static value" "$result" "$target"

# variable value
result="$(colonConfig "Two" "$directory/first.conf" "default")"
target="myX"
assertEqual "Dynamic value" "$result" "$target"

# mixed value
result="$(colonConfig "Three" "$directory/first.conf" "default")"
target="myX/and myY/"
assertEqual "Mixed value" "$result" "$target"

# variable with spaced content
result="$(colonConfig "Four" "$directory/first.conf" "default")"
target="my little space train"
assertEqual "Spaced content in variable" "$result" "$target"

# tilde
result="$(colonConfig "Five" "$directory/first.conf" "default")"
target="$HOME"
assertEqual "Tilde expansion" "$result" "$target"

