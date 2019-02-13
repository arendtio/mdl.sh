#!/bin/sh

implementation="$1"
directory="$2"

module "identifier" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-0.9.2.sh" "cksum-2374238394"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.4.sh" "cksum-566303087"

DEBUG_NAMESPACE="IDENTIFIER_SPEC"

# no argument
result="0"
identifier >/dev/null 2>&1 || result="$?" && true
target="1"
assertEqual "Fail on no argument" "$result" "$target"

# too many arguments
result="0"
identifier "A" "B">/dev/null 2>&1 || result="$?" && true
target="1"
assertEqual "Fail on too many arguments" "$result" "$target"

# basic url test
result="$(identifier "https://mdl.sh/hello-world/hello-world-1.0.0.sh")"
target="https://mdl.sh/hello-world/hello-world-1.0.0.sh"
assertEqual "Basic URL" "$result" "$target"

# path to existing file test
file="$directory/my-test-module-1.0.0.sh"
touch "$file"
result="$(identifier "$file")"
target="$file"
assertEqual "Path to existing file" "$result" "$target"

# half url test
result="$(identifier "my-short/url-module-1.0.0.sh")"
target="https://mdl.sh/my-short/url-module-1.0.0.sh"
assertEqual "Half URL" "$result" "$target"

# long half url test
result="$(identifier "my/long/url-module-1.0.0.sh")"
target="https://mdl.sh/my/long/url-module-1.0.0.sh"
assertEqual "Long half URL" "$result" "$target"

# pure package name test
result="$(identifier "hello-world-1.0.0.sh")"
target="https://mdl.sh/hello-world/hello-world-1.0.0.sh"
assertEqual "Pure package name" "$result" "$target"

