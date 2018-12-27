#!/bin/sh

implementation="$1"
directory="$2"

file="$directory/test.conf"

module "colonValueExists" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.0.sh" "cksum-811392305"

# file does not exist
if colonValueExists "Zero" "$file" >/dev/null; then
	error "TEST: colonValue does not return a non-zero value if the file doesn't exist" 1
fi

# create a file
printf 'One: A\n' >$file

# Key exists
target=""
result="$(colonValueExists "One" "$file")"
assertEqual "Key exists (return value)" "$?" "0"
assertEqual "Key exists (output)" "$result" "$target"

# Key does not exist
if colonValueExists "Two" "$file" >/dev/null; then
	error "TEST: colonValueExists does not return an non-zero value if the key does not exist" 1
fi

