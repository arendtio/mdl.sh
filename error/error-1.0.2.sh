#!/bin/sh

# mandatory:
# error message
msg="$1"

# optional:
# exit code
code="${2:-1}"

printf '%s\n' "$msg" >&2
exit "$code"
