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

# macOS gets some special treatment
# $OSTYPE is not part of POSIX
# shellcheck disable=SC2039
if [ "$(printf '%s' "${OSTYPE:-}" | cut -c 1-6)" = "darwin" ]; then
	cmdDry="$(printf "mktemp -t '%s' -u" "$keyword")"
	cmdDir="$(printf "mktemp -d -t '%s'" "$keyword")"
	cmdFile="$(printf "mktemp -t '%s-pointer'" "$keyword")"
else
	# Note: mktemp on android seems to have problems with templates,
	# so we include the template here to trigger the problem early
	cmdDry="$(printf "mktemp -u --tmpdir '%s.XXXX'" "$keyword")"
	cmdDir="$(printf "mktemp -d --tmpdir '%s.XXXX'" "$keyword")"
	cmdFile="$(printf "mktemp --tmpdir '%s-pointer.XXXX'" "$keyword")"
fi

# find the directory that mktemp uses by default
if ! dry="$(eval "$(printf '%s' "$cmdDry")")"; then
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

	if ! pointer="$(eval "$(printf '%s' "$cmdDir")")"; then
		printf 'mktemp -d "%s.XXXX" failed' "$keyword" >&2
		return $?
	fi
	if ! pointerFile="$(eval "$(printf '%s' "$cmdFile")")"; then
		printf 'mktemp "%s-pointer.XXXX" failed' "$keyword" >&2
		return $?
	fi
	printf '%s\n' "$pointer" >"$pointerFile"
fi

printf '%s\n' "$pointer"
