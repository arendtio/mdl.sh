#!/bin/sh
# This module provides an easy way to create a tmp directory
# which can be found by other programs which use the same keyword.

# This module depends on mktemp
if ! command -v mktemp >/dev/null 2>&1; then
	return 1
fi

keyword="$1"

# Set directory to the same value every time this script gets invoked by the same user
# Note: This should work because in /tmp you can read only your own files

directory="${TMPDIR:-/tmp}"

# search pointer value
pointer="$(head -n1 $directory/"$keyword"-pointer* 2>/dev/null || true)"

# create, if it does not exist
if [ "$pointer" = "" ] || [ ! -d "$pointer" ]; then
	# remove old pointer
	rm -rf $directory/"$keyword"*
	# mktemp -t does not seem to be supported by the android version of mktemp
	# but is also not necessary
	if ! pointer="$(mktemp -p "$directory" -d "$keyword.XXXX")"; then
		printf 'mktemp -d "%s.XXXX" failed' "$keyword" >&2
		return $?
	fi
	if ! pointerFile="$(mktemp -p "$directory" "$keyword-pointer.XXXX")"; then
		printf 'mktemp "%s-pointer.XXXX" failed' "$keyword" >&2
		return $?
	fi
	echo "$pointer" >"$pointerFile"
fi

echo "$pointer"
