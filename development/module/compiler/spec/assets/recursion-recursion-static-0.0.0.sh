#!/bin/sh

# start module https://mdl.sh/development/module/compiler/spec/assets/recursion-0.0.0.sh
recursion() { (
set -eu
# start module https://mdl.sh/development/module/compiler/spec/assets/noop-0.0.0.sh
noop() { (
set -eu

) }
# end module https://mdl.sh/development/module/compiler/spec/assets/noop-0.0.0.sh
) }
# end module https://mdl.sh/development/module/compiler/spec/assets/recursion-0.0.0.sh
