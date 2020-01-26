#!/bin/sh

# TODO: add an exit statement which the compiler removes to ensure this script
# is only being used in the static version

# define a function called 'module' which does exactly what module-core does
module "module" "https://mdl.sh/development/module/core/module-core-0.9.21.sh" "cksum-2230551446"
