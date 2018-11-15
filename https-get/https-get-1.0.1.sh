#!/bin/sh

# mandatory:
url="$1"

module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"

# find out command- v http client is available and use it
if command -v curl >/dev/null 2>&1; then
	curl -sL "$url"
elif command -v wget >/dev/null 2>&1; then
	wget -qO - "$url"
elif command -v openssl >/dev/null 2>&1; then
	host="$(echo "$url" | sed -e 's;^[^/]\+://;;' -e 's;[/:].*$;;')"
	path="$(echo "$url" | sed -e 's;^[^/]\+://[^/]\+/;/;')" # with leading /
	port="$(echo "$url" | sed -e 's;^[^/]\+://[^/]\+:\([0-9]\+\)/.*$;\1;')"
	if [ "$port" = "$url" ]; then
		port="443"
	fi

	# sed to remove the headers form the output
	printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$path" "$host" | openssl s_client -quiet -connect "$host:$port" 2>/dev/null | sed '1,/^\r$/d'
else
	error "None of curl, wget and openssl is available. Exiting."
fi
