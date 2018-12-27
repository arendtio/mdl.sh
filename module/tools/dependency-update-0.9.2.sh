#!/bin/sh

set -eEu

# mandatory
action="$1"
mdlRepository="$2"

# optional:
confirmation="${3:-no}"
moduleName="${4:-*-*.*.*.sh}"

if [ "$#" -lt 2 ]; then
	echo "not enought arguments"
	exit 1
fi

if [ "$action" != "scan" ] && [ "$action" != "update" ]; then
	printf 'Unknown action "%s". Aborting\n' "$action"
	exit 1
fi

eval "$(curl -fsL "https://mdl.sh/latest")"
module "debug" "https://mdl.sh/debug/debug-0.9.0.sh" "cksum-4035594112"
module "moduleChecksum" "https://mdl.sh/module/module-checksum-0.9.0.sh" "cksum-24661179"

# search the targetDirectory for modules and make a list (do not include static files)
moduleList="$(find "$mdlRepository" -iname "$moduleName" | grep -v -- '-static-[^-]*.sh$' | sed 's;^./;;' )"

debug "$(printf 'Module List:\n%s' "$moduleList")" "MODULE_DEPENDENCY" 1

checkModules() {
	# moduleList="$1"

	debug "checkModules: $1" "MODULE_DEPENDENCY" 1

	if [ "$1" = "" ]; then
		return 0
	fi

	# mind the subshell
	echo "$1" | while read modulePath; do
		if [ "$(newestSameMajor "$modulePath")" != "$modulePath" ]; then
			# this file is not the newest version for this major version
			# so we don't need to check if it is updatable as there is a newer version already
			# let's skip it
			debug "Skipping $modulePath" "MODULE_DEPENDENCY" 1
			continue;
		fi
		debug "Processing $modulePath" "MODULE_DEPENDENCY" 1
		updatable "$modulePath"
	done
}

extractDependencies() {
	grep -ri "^[ $(printf '\t')]*module " "$1" \
		| sed "s;^[^\"']*[\"'][^\"']*[\"'][^\"']*[\"']\([^\"']*\)[\"'].*$;\1;" \
		| sed 's;^https://mdl.sh/;;'
}

# This tool knows two reasons to update a package:
#
# 1. for a dependency exists a newer version
# 2. a dependency can be updated
#
# The following function generates a list of all modules that should be
# updated. So list is ordered so that updating all packages to bottom
# will update all packages in one run.
#
# The function assumes that modulePath ($1) is already the latest version
# of that package.
updatable() {(
	modulePath="$1"

	debug "updatable check for $modulePath" "MODULE_DEPENDENCY" 2

	moduleRequiresUpdate="false"

	# the function recursively calls itself for all dependenies
	# find dependencies
	dependencies="$(extractDependencies "$modulePath")"

	debug "$(printf '%s has the following dependencies:\n%s\n' "$modulePath" "$dependencies")" "MODULE_DEPENDENCY" 3

	# find newest version for each dependency
	if [ "$dependencies" != "" ]; then
		newestDependencies="$(
			echo "$dependencies" | while read dependency; do
				newestSameMajor "$dependency"
			done
		)"

		debug "$(printf 'Newest dependencies:\n%s\n' "$newestDependencies")" "MODULE_DEPENDENCY" 4

		# if any of the dependencies is outdated then this module must be updated
		if [ "$dependencies" != "$newestDependencies" ]; then
			debug "$(printf 'At least one dependency has a newer version already\n' "$newestDependencies")" "MODULE_DEPENDENCY" 4
			moduleRequiresUpdate="true"
		fi

		# check if any dependencies should be updated before us
		updatableDeps="$(
			# mind the subshell
			echo "$newestDependencies" | while read dependency; do
				updatable "$dependency"
			done
		)"

		if [ "$updatableDeps" != "" ]; then
			# print our dependencies before us
			echo "$updatableDeps"
			moduleRequiresUpdate="true"
		else
			debug "$(printf 'No dependency need to be updated for %s\n' "$modulePath")" "MODULE_DEPENDENCY" 3
		fi
	else
		debug "$(printf 'No dependencies at all in %s\n' "$modulePath")" "MODULE_DEPENDENCY" 3
	fi

	if [ "$moduleRequiresUpdate" == "true" ]; then
		debug "$modulePath is UPDATEABLE" "MODULE_DEPENDENCY" 2
		echo "$modulePath"
	fi
)}

newestSameMajor() {
	modulePath="$1"

	# kinda hacky, but should suffice for the moment
	ls -t "$(echo "$modulePath" | sed 's;-\([0-9]\+\)\.[^-]*\.sh$;-\1.;')"*".sh" | head -n 1
}

# awk version of uniq to preserve order: https://unix.stackexchange.com/questions/48713/how-can-i-remove-duplicates-in-my-bash-history-preserving-order
updateList="$(checkModules "$moduleList" | awk '!x[$0]++')"

# if scan action exit here
if [ "$action" = "scan" ]; then
	echo "$updateList"
	exit
else
	debug "$(printf 'Full updateList:\n%s' "$updateList")" "MODULE_DEPENDENCY" 1
fi

# try to update the listed modules
updateModule() {(
	oldModule="$1"
	# copy newest version to next version
	patchVersion="$(printf '%s' "$oldModule" | sed 's;.*\.\([0-9]\+\)\.sh$;\1;')"
	newModule="$(printf '%s' "$oldModule" | sed 's;\.[0-9]\+\.sh$;\.;')$((patchVersion + 1)).sh"
	debug "$oldModule will be updated to $newModule" "MODULE_DEPENDENCY" 1

	# loop the lines of the old file
	newContent="$(
		cat "$oldModule" | while IFS="" read -r p || [ -n "$p" ]; do
			# check if the line contains a dependency
			signatureCoreRegex="module[^\"']\\+[\"'][^\"']\\+[\"'][^\"']\\+"
			if echo "$p" | grep "$signatureCoreRegex[\"']https://mdl.sh/" >/dev/null; then
				debug "Dependency Line: $p" "MODULE_DEPENDENCY" 2

				firstPart="$(echo "$p" | sed "s;\\(^[ \\t]*$signatureCoreRegex\\)[\"']https://mdl.sh/.*$;\\1;")"
				oldDep="$(echo "$p" | sed "s;\\(^[ \\t]*$signatureCoreRegex\\)[\"']https://mdl.sh/\\([^\"']\\+\\.sh\\)[\"']\\([^\"']\\+[\"']\([^\"'-]\\+\)-[^\"']\\+[\"'].*\\)*$;\\2;")"
				hashFunc="$(echo "$p" | sed "s;\\(^[ \\t]*$signatureCoreRegex\\)[\"']https://mdl.sh/[^\"']\\+[\"']\\([^\"']\\+[\"']\([^\"'-]\\+\)-[^\"']\\+[\"'].*\\)*$;\\2;")"
				newDep="$(newestSameMajor "$oldDep")"

				debug "First Part: $firstPart" "MODULE_DEPENDENCY" 3
				debug "oldDep: $oldDep" "MODULE_DEPENDENCY" 3
				debug "NewDep: $newDep" "MODULE_DEPENDENCY" 3
				debug "HashFunc: $hashFunc" "MODULE_DEPENDENCY" 3

				# the hash part is optional
				if [ "$hashFunc" != "" ]; then
					newChecksum="$(moduleChecksum "$(cat "$newDep")")"
					debug "NewChecksum: $newChecksum" "MODULE_DEPENDENCY" 3
					echo "$firstPart\"https://mdl.sh/$newDep\" \"$newChecksum\""
				else
					debug "No Checksum" "MODULE_DEPENDENCY" 3
					echo "$firstPart\"https://mdl.sh/$newDep\""
				fi
			else
				echo "$p"
			fi
		done
	)"

	debug "$(printf 'New Module content:\n%s\n' "$newContent")" "MODULE_DEPENDENCY" 5

	# write new file and print diff
	if [ ! -f "$newModule" ] && [ "$confirmation" = "yes" ]; then
		echo "$newContent" > "$newModule"
		diff -u "$oldModule" "$newModule" || true
	else
		echo "$newContent" | diff -u "$oldModule" - || true
	fi
)}

if [ "$updateList" = "" ]; then
	echo "Nothing to Update. Exiting."
	exit 0
fi

echo "$updateList" | while read -r candidate; do
	updateModule "$candidate"
done

