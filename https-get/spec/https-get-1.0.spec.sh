#!/bin/sh

implementation="$1"
directory="$2"

module "httpsGet" "$implementation"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.5.sh" "cksum-566303087"

DEBUG_NAMESPACE="HTTPS_GET_SPEC"

## normal test
result="$(httpsGet "https://mdl.sh/hello-world/hello-world-1.0.0.sh" | cksum)"
target="1346054948 31"
assertEqual "Basic hello-world fetch" "$result" "$target"
