#!/bin/sh
# This module provides an easy way to create a tmp directory
# which can be found by other programs which use the same keyword.

if [ "$#" -ne 1 ]; then
	printf 'Not enough arguments\n' >&2
	exit 1
fi

keyword="$1"

if [ "$keyword" = "" ]; then
	printf 'The keyword must not be empty\n' >&2
	exit 1
fi

# This module depends on mktemp
if ! command -v mktemp >/dev/null 2>&1; then
	printf 'mktemp is unavailable\n' >&2
	exit 1
fi

# find the directory that mktemp uses by default
# Note: mktemp on android seems to have problems with templates,
# so we include the template here to catch the problem early
if ! dry="$(mktemp -u --tmpdir "$keyword.XXXX")"; then
	printf 'mktemp dry-run failed\n' >&2
	exit 1
fi

directory="$(dirname "$dry")"

# Set pointer to the same value every time this script gets invoked by the same user
# Note: This should work because in /tmp you can read only your own files

# search pointer value
pointer="$(head -n1 "$directory/$keyword"-pointer* 2>/dev/null || true)"

# create, if it does not exist
if [ "$pointer" = "" ] || [ ! -d "$pointer" ]; then
	for p in "$directory/$keyword"-pointer*; do
		if [ "$p" = "$directory/$keyword-pointer*" ]; then
			continue
		fi
		# warn about existing but non-functional pointers
		printf 'WARNNIG: Found orphaned pointer %s\n' "$p" >&2
	done

	# mktemp -t does not seem to be supported by the android version of mktemp
	# but is also not necessary
	if ! pointer="$(mktemp -d -p "$directory" "$keyword.XXXX")"; then
		printf 'mktemp -d "%s.XXXX" failed' "$keyword" >&2
		return $?
	fi
	if ! pointerFile="$(mktemp -p "$directory" "$keyword-pointer.XXXX")"; then
		printf 'mktemp "%s-pointer.XXXX" failed' "$keyword" >&2
		return $?
	fi
	printf '%s\n' "$pointer" >"$pointerFile"
fi

printf '%s\n' "$pointer"
