#!/bin/sh
set -eu

# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# mandatory parameters
oldModule="$1" # path to file

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "colonConfigEvaluated" "https://mdl.sh/config/colon/colon-config-evaluated/colon-config-evaluated-0.9.8.sh" "cksum-1865011839"
module "findVersion" "https://mdl.sh/network/services/mdl/find-version/find-version-0.9.9.sh" "cksum-489523316"
module "moduleChecksum" "https://mdl.sh/development/module/checksum/module-checksum-1.0.0.sh" "cksum-2672654258"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "whitespaceProtection" "https://mdl.sh/content/transformer/whitespace-protection/whitespace-protection-0.9.1.sh" "cksum-2675970117"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_UPDATE"

# try to update the listed modules
# copy newest version to next version
if [ "$oldModule" = "${oldModule%.spec.sh}" ]; then
	patchVersion="$(printf '%s' "$oldModule" | sed 's;.*\.\([0-9]\{1,\}\)\.sh$;\1;')"
	newModule="$(printf '%s' "$oldModule" | sed 's;\.[0-9]\{1,\}\.sh$;\.;')$((patchVersion + 1)).sh"
else
	newModule="$oldModule"
fi
debug "$oldModule will be updated to $newModule" 1

# regex explanation:
# \1 = whitespace prefix + "module"
# \2 = whitespace after module + first quote
# \3 = function name
# \4 = quotes and whitespace between function name and URL
# \5 = URL
# \6 = should not be used; whole optional checksum part
# \7 = quotes and whitespace after URL
# \8 = checksum
# \9 = whitespace suffix
mdlRegex="$(printf '%s' \
	'^\([[:space:]]*module\)' \
	'\([[:space:]]\{1,\}["'"'"']\{,1\}\)' \
	'\([[:alnum:]]\{1,\}\)' \
	'\([\"'"'"']\{,1\}[[:space:]]\{1,\}["'"'"']\{,1\}\)' \
	'\([^[:space:]"'"'"']\{1,\}\)' \
	'\(' \
		'\([\"'"'"']\{,1\}[[:space:]]\{1,\}["'"'"']\{,1\}\)' \
		'\([^[:space:]"'"'"']\{1,\}\)' \
		'\|' \
	'\)' \
	'\([\"'"'"']\{,1\}[[:space:]]*\)$')"

# '\(\"\([^\"]\{1,\}\)\"\|'"'"'\([^'"'"']\{1,\}\)'"'"'\|\([^[:space:]]\{1,\}\)\)' \

userConfig=${XDG_CONFIG_HOME:-~/.config}/"module.sh/module.conf"
key="local-repository"
repo="$(colonConfigEvaluated "$key" "$userConfig" none)"
if [ "$repo" = "none" ]; then
	error "No local-repository could be found in the config file."
fi

debug "Using local-repo $repo" 1

rewriteLine() { (
	p="$1"
	debug "Line $p" 3
	# check if the line contains a dependency
	if printf '%s\n' "$p" | grep "$mdlRegex" >/dev/null; then
		debug "Dependency Line: $p" 2

		beforeUrl="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\1\\2\\3\\4;")"
		oldUrl="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\5;")"
		beforeChecksum="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\7;")"
		checksum="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\8;")"
		suffix="$(printf '%s\n' "$p" | sed "s;$mdlRegex;\\9;")"
		hashFunc="$(printf '%s\n' "$checksum" | sed 's;^\([^-]\{1,\}\)-.*$;\1;')"

		debug "BeforeUrl: $beforeUrl" 3
		debug "OldUrl: $oldUrl" 3
		debug "BeforeChecksum: $beforeChecksum" 3
		debug "Checksum: $checksum" 3
		debug "Suffix: $suffix" 3
		debug "HashFunc: $hashFunc" 3

		# TODO: this is mdl.sh specific. We need a solution for other repos too.
		if [ "$oldUrl" != "${oldUrl%.spec.sh}" ]; then
			# specs should not be dependencies... just in case
			debug "Detected spec '$oldUrl' as dependency in '$oldModule'. Not good." 0
			newDep="$oldUrl"
		else
			oldDep="$(printf '%s' "$oldUrl" | sed 's;^https://[-a-zA-Z0-9_\.:]\{1,\}/;/;')"
			debug "OldDep: $oldDep" 3
			newDep="$(findVersion latestSameMajor "$oldDep" | sed 's;^/;https://mdl.sh/;')"
		fi

		debug "NewDep: $newDep" 3

		if [ "$newDep" = "" ]; then
			error "The newDep for '$oldDep' could not be found in repo '$repo'" 1
			exit 1
		fi

		# the hash part is optional
		if [ "$hashFunc" != "" ]; then
			newDepPath="$(printf '%s/%s' "$repo" "$(printf '%s' "$newDep" | sed 's;^[^\/:]*://;;')")"
			newChecksum="$(moduleChecksum "$hashFunc" <"$newDepPath")"
			debug "NewChecksum: $newChecksum" 3

			printf '%s%s%s%s%s\n' "$beforeUrl" "$newDep" "$beforeChecksum" "$newChecksum" "$suffix"
		else
			debug "No Checksum" 3
			printf '%s%s%s\n' "$beforeUrl" "$newDep" "$suffix"
		fi
	else
		printf '%s\n' "$p"
	fi
) }

# loop the lines of the old file
newContent="$(
	# read $oldModule line-by-line
	# we tunnel the return code through the pipe while applying the whitespace protection
	# https://unix.stackexchange.com/a/70675/130618
	# if this causes trouble in the future, simply applying the whitespace protection before rewriting might be a quick and dirty solution
	# shellcheck disable=SC2086
	( ( ( ( while IFS="" read -r p || [ -n "$p" ]; do
		rewriteLine "$p" || exit $?
	done <"$oldModule"; printf '%s\n' "$?" >&3 ) | whitespaceProtection add >&4 ) 3>&1 ) | (read -r xs; exit $xs) ) 4>&1
)"
rc="$?"
if [ "$rc" -ne 0 ]; then
	error "Rewrite failed." "$rc"
	exit "$rc"
fi

debug "$(printf 'New Module content (rc %s)  (with whitespace protection):\n%s\n' "$rc" "$newContent")" 5

# write new file and print diff
#printf '%s' "$newContent" | diff -u "$oldModule" - || true
# if the file does not exists or is a spec, write it
if [ ! -f "$newModule" ] || [ "$newModule" != "${newModule%.spec.sh}" ]; then
	debug "Writing: '$newModule'" 1
	printf '%s' "$newContent" | whitespaceProtection remove > "$newModule"
	debug "$(diff -u "$oldModule" "$newModule" || true)" 2
else
	error "NewModule '$newModule' exists and is no spec. Aborting." 1
fi

