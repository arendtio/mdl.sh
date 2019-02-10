#!/bin/sh

# parameters are defined in colon-config

# dependencies
module "colonConfig" "https://mdl.sh/colon-config/colon-config-0.9.3.sh" "cksum-3807881313"

value="$(colonConfig "$@")"
eval "printf '%s ' $value | sed 's/ \$//' " # to evaluate variables like: $XDG_DATA_HOME
printf '\n' # and terminate with a newline
