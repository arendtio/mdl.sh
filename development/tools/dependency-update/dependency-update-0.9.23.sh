#!/bin/sh
set -eu

# example:
# ./module/tools/dependency-update-0.9.4.sh "no"

# describtion of the algorithm:
# 1. we make a list of modules for which we want to check if they should be updated (e.g. modules)
# 2. for every module in that list, we check if one of the dependencies has a new version or is updatable and create list of updatable modules
# 3. we iterate over the ordered list of updateable modules and update them all
#
# this is inefficient as many modules are bing checked multiple times for being updatable (e.g. debug, error, etc.)
# - one idea to optimize the runtime is to give the already known updatable modules as another input, as checking against a list should be faster

# check number of arguments
if [ "$#" -gt 3 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

# optional parameters
confirmation="${1:-no}"
scanOffset="${2:-mdl.sh}"
scanPattern="${3:-*.*.sh}"

# dependencies
if [ "$(command -v module 2>/dev/null | cut -c1)" = "/" ]; then eval "$(module init)"; elif ! command -v module >/dev/null 2>&1; then eval "$(h=mdl.sh; p=/latest; u="https://$h$p"; curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d') )"; fi
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "colonConfigEvaluated" "https://mdl.sh/config/colon/colon-config-evaluated/colon-config-evaluated-0.9.8.sh" "cksum-1865011839"
module "filterOld" "https://mdl.sh/development/module/dependency/filter/filter-old-0.9.2.sh" "cksum-321090859"
module "updatable" "https://mdl.sh/development/module/dependency/updatable/updatable-0.9.3.sh" "cksum-437652222"
module "update" "https://mdl.sh/development/module/dependency/update/update-0.9.4.sh" "cksum-1730908725"

# The debug module uses this variable
export DEBUG_NAMESPACE="MODULE_DEPENDENCY_UPDATE_TOOL"

# check for the local repository
# check if the env variable is set first
if [ -z "${CONFIG_LOCAL_REPOSITORY+x}" ]; then
	userConfig=${XDG_CONFIG_HOME:-~/.config}/"module.sh/module.conf"
	key="local-repository"
	repo="$(colonConfigEvaluated "$key" "$userConfig" none)"
	if [ "$repo" = "none" ]; then
		error "Local-repository could not be found in config. Exiting." 1
	fi
else
	repo="$CONFIG_LOCAL_REPOSITORY"
fi

debug "$(printf 'Using repository %s\n' "$repo")" 1
cd "$repo" || exit 1

# search the targetDirectory for modules and make a list (do not include static files)
moduleList="$(find "./$scanOffset" -iname "$scanPattern" | grep -v -- '-static-[^-]*.sh$' | grep -v '/spec/assets/' | sed 's;^./;;' )"

debug "$(printf 'Module List:\n%s' "$moduleList")" 1

# awk version of uniq to preserve order: https://unix.stackexchange.com/questions/48713/how-can-i-remove-duplicates-in-my-bash-history-preserving-order
updateList="$(printf '%s\n' "$moduleList" \
	| while IFS="" read -r modUpdate; do debug "before filter old $modUpdate" 2; printf '%s\n' "$modUpdate"; done \
	| filterOld \
	| while IFS="" read -r modUpdate; do debug "after filter old $modUpdate" 2; printf '%s\n' "$modUpdate"; done \
	| sed 's;^;https://;' \
	| while IFS="" read -r modUpdate; do updatable "$modUpdate"; done \
	| sed 's;^[^\/:]*://;;' \
	| awk '!x[$0]++')"

debug "$(printf 'Update List:\n%s' "$updateList")" 1

if [ "$updateList" = "" ]; then
	printf 'Nothing to Update. Exiting.\n'
	exit 0
fi

if [ "$confirmation" = "yes" ]; then
	printf '%s\n' "$updateList" | while IFS="" read -r candidate; do
		update "$candidate"
	done
else
	printf 'UpdateList:\n%s\n' "$updateList"
fi
