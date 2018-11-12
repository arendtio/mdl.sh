#!/bin/sh

# mandatory:
# error message
msg="$1"

# optional:
# exit code
code="${2:-1}"

echo "$msg" >&2
exit "$code"
