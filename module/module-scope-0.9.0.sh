#!/bin/sh

name="$1"
moduleContent="$2"

printf '%s() {(\n%s\n)}\n' "$name" "$moduleContent"
