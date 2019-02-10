#!/bin/sh

# parameters are defined in colon-config

# dependencies
module "colonConfig" "https://mdl.sh/colon-config/colon-config-0.9.4.sh" "cksum-104618752"

value="$(colonConfig "$@")"
eval "printf '%s ' $value | sed 's/ \$//' " # to evaluate variables like: $XDG_DATA_HOME
printf '\n' # and terminate with a newline
