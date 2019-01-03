#!/bin/sh

name="$1"
moduleContent="$2"

printf '%s() { (\nset -eu\n%s\n) }\n' "$name" "$moduleContent"
