#!/bin/sh

# parameters are defined in colon-config

# dependencies
module colonConfig "https://mdl.sh/colon-config/colon-config-0.9.0.sh"

value="$(colonConfig "$@")"
eval "printf '%s ' $value | sed 's/ \$/\\n/g'" # to evaluate variables like: $XDG_DATA_HOME
