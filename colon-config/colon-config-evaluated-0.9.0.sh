#!/bin/sh

# parameters are defined in colon-config

# dependencies
module colonConfig "https://mdl.sh/colon-config/colon-config-0.9.0.sh"

value="$(colonConfig "$@")"
eval "printf '%s\\n' \"$value\"" # to evaluate variables like: $XDG_DATA_HOME
