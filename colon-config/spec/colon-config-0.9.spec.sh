#!/bin/sh

implementation="$1"
directory="$2"

module "colonConfig" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.4.sh" "cksum-566303087"

# This can be used to debug print all asserts with
# DEBUG_COLON_CONFIG_SPEC=2 ./run-all.sh
# mind the DEBUG_ before the namespace
DEBUG_NAMESPACE="COLON_CONFIG_SPEC"

# one argument (invalid)
if colonConfig "whatever" >/dev/null 2>&1; then
	error "TEST: colonConfig does not return a non-zero value if called with just one argument" 1
fi

# no config (just default)
result="$(colonConfig "Zero" "default")"
target="default"
assertEqual "No config (just default)" "$result" "$target"

# empty default value
result="$(colonConfig "Zero" "")"
target=""
assertEqual "Empty default" "$result" "$target"

# file does not exist
result="$(colonConfig "Zero" "$directory/no.conf" "default")"
target="default"
assertEqual "File does not exist" "$result" "$target"

# create config files
printf 'One: A\n' >$directory/first.conf
printf 'One: AA\nTwo: BB\n' >$directory/second.conf
printf 'Two: BBB\nThree: CCC\n' >$directory/third.conf
printf 'Four: DDDD\n' >$directory/fourth.conf

# one config (value does not exist)
result="$(colonConfig "Zero" "$directory/first.conf" "default")"
target="default"
assertEqual "One config (value does not exist)" "$result" "$target"

# one config (value exists)
result="$(colonConfig "One" "$directory/first.conf" "default")"
target="A"
assertEqual "One config (value exists)" "$result" "$target"

# two configs (both containing the key)
result="$(colonConfig "One" "$directory/first.conf" "$directory/second.conf" "default")"
target="A"
assertEqual "Two configs (with key in both)" "$result" "$target"

# two configs (one value)
result="$(colonConfig "Two" "$directory/first.conf" "$directory/second.conf" "default")"
target="BB"
assertEqual "Two configs (second with key)" "$result" "$target"

# three configs
result="$(colonConfig "Three" "$directory/first.conf" "$directory/second.conf" "$directory/third.conf" "default")"
target="CCC"
assertEqual "Three configs" "$result" "$target"

# three configs (first config doesn't exist, value in third)
result="$(colonConfig "Three" "$directory/no.conf" "$directory/second.conf" "$directory/third.conf" "default")"
target="CCC"
assertEqual "Three configs (first doesn't exist, key in third)" "$result" "$target"

# four configs (value present in last config)
result="$(colonConfig "Four" "$directory/first.conf" "$directory/second.conf" "$directory/third.conf" "$directory/fourth.conf" "default")"
target="DDDD"
assertEqual "Four configs (key in last)" "$result" "$target"

# four configs (key doesn't exist)
result="$(colonConfig "Zero" "$directory/first.conf" "$directory/second.conf" "$directory/third.conf" "$directory/fourth.conf" "default")"
target="default"
assertEqual "Four configs (key does not exist)" "$result" "$target"
