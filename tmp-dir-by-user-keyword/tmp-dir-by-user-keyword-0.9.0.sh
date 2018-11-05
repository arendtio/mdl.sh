#!/bin/sh

keyword="$1"

# Set directory to the same value every time this script gets invoked by the same user
# Note: This should work because in /tmp you can normally only read your own files

# search pointer value
pointer="$(head -n1 /tmp/"$keyword"-pointer* 2>/dev/null || true)"

# create, if not exists
if [ "$pointer" = "" ] || [ ! -d "$pointer" ]; then
	# remove old pointer
	rm -rf /tmp/"$keyword"*
	pointer="$(mktemp -d -t "$keyword.XXXX")"
	pointerFile="$(mktemp -t "$keyword-pointer.XXXX")"
	echo "$pointer" >"$pointerFile"
fi

echo "$pointer"
