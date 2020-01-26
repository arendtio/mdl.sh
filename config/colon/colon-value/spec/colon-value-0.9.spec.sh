#!/bin/sh

implementation="$1"
directory="$2"

file="$directory/test.conf"

module "colonValue" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"

# file does not exist
if colonValue "Zero" "$file" >/dev/null; then
	error "TEST: colonValue does not return a non-zero value if the file doesn't exist" 1
fi

# create a file
printf 'One: A\nTwo:B\nFour:\nFive: E \nSix: F:F\n' >"$file"

# colon with space
result="$(colonValue "One" "$file")"
target="A"
assertEqual "Colon with space" "$result" "$target"

# colon without space
result="$(colonValue "Two" "$file")"
target="B"
assertEqual "Colon without space" "$result" "$target"

# key does not exist
result="$(colonValue "Three" "$file")"
target=""
assertEqual "Non-existing key" "$result" "$target"

# empty value
result="$(colonValue "Four" "$file")"
target=""
assertEqual "Empty value" "$result" "$target"

# value with trailing space
result="$(colonValue "Five" "$file")"
target="E"
assertEqual "Value with trailing space" "$result" "$target"

# value with colon
result="$(colonValue "Six" "$file")"
target="F:F"
assertEqual "Value with colon" "$result" "$target"
