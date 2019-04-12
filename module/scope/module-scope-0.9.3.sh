#!/bin/sh

name="$1"
moduleContent="$2"

# awk: exit if the line does not start with a # otherwise {print $0}
moduleHeader="$(printf '%s\n' "$moduleContent" | awk '!/^#/ {exit}; {print $0}')"

if printf '%s\n' "$moduleHeader" | grep '^#[[:space:]]*guarantees:[[:space:]]*intentional-side-effects' >/dev/null 2>&1; then
	# no sub-shell, if the author promises to care about side-effects
	printf '%s() {\n%s\n}\n' "$name" "$moduleContent"
else
	# with sub-shell, default
	printf '%s() { (\nset -eu\n%s\n) }\n' "$name" "$moduleContent"
fi

