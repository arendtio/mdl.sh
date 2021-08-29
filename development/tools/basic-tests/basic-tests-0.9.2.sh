#!/bin/sh
# When module.sh is being run for the first time on a new OS, it sometimes
# fails. But without a working module function, it is hard to find the module
# which contains the error. Therefore, this script provides a minimal version
# which has better chances to run without error. But be aware, that this vesion
# is less secure and has fewer features.

set -eu

# check number of arguments
if [ "$#" -gt 0 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

basicCacheDir="$(mktemp -d)"
printf 'Cache Directory: %s\n' "$basicCacheDir"

clearCache() {
	if [ "$basicCacheDir" != "" ] && [ -d "$basicCacheDir" ]; then
		rm -r "$basicCacheDir"
	fi
}

clearTestSetup() {
	if [ "$directory" != "" ] && [ -d "$directory" ]; then
		rm -r "$directory"
	fi
}

trapExit(){
	clearTestSetup
	clearCache
}

# the ultra simple version
module() {
	# $1 = function name
	# $2 = url
	# s = simple -> without protocol
	# h = host
	# p = path
	eval "$(
		s=${2#*//};
		h=${s%%/*};
		p=/${2#*//*/};
		u="https://$h$p";
		moduleCacheDir="${basicCacheDir}$(dirname "$p")"
		moduleCacheFile="${basicCacheDir}$p"

		if [ -e "$moduleCacheFile" ]; then
			##printf 'CACHE %s\n' "$2" >&2
			src="$(cat "$moduleCacheFile")"
		else
			##printf 'GET %s\n' "$2" >&2
			# download via basic https-get
			src="$(curl -fsL "$u" || wget -q "$u" -O - || ( printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$p" "$h" | openssl s_client -quiet -connect "$h:443" 2>/dev/null | sed '1,/^\r$/d'))"
			if [ "${src#'#'}" = "$src" ]; then
				printf '|---------- Head 10 ---------->\n' >&2
				printf '%s\n' "$src" | head -n 10 >&2
				printf '|----------------------------->\n' >&2
				printf 'The fetched module %s does not start with a shebang. exiting.' "$2" >&2
				exit 1
			fi
			#cache it
			mkdir -p "$moduleCacheDir"
			printf '%s\n' "$src" > "$moduleCacheFile"
		fi

		# wrap in function
		# add a subshell if intentional-side-effects is not present in initial comment
		moduleHeader="$(printf '%s\n' "$src" | awk '!/^#/ {exit}; {print $0}')"
		if printf '%s\n' "$moduleHeader" | grep '^#[[:space:]]*guarantees:[[:space:]]*intentional-side-effects' >/dev/null 2>&1; then
			printf '%s() {\n%s\n}\n' "$1" "$src"
		else
			printf '%s() { (\nset -eu\n%s\n) }\n' "$1" "$src"
		fi
	)"

}

runTest() {
	# $1 = spec function name
	# $2 = module url

	# prepare a directory
	directory="$(mktemp -d)"
	ret="$?"
	if [ "$directory" = "" ] || [ ! -d "$directory" ] || [ "$ret" -ne 0 ]; then
		printf 'TEST PREPARTION: mktemp failed\n'
		exit 2
	fi

	trap trapExit EXIT

	# execute the spec
	( "$1" "$2" "$directory" )
	rc="$?"
	if [ "$rc" = "0" ]; then
		printf '[PASS] %s\n' "$2"
	else
		# set -e should make this case impossible
		printf '[FAIL] %s\n' "$2"
	fi

	trap - EXIT
	clearTestSetup
}

printf 'Starting tests:\n'
# even though we use 'module ...' we can not compile a static version as the spec uses a variable to load the module
base="https://mdl.sh"

spec="errorSpec"
module  "$spec" "$base/development/error/spec/error.spec.sh"
runTest "$spec" "$base/development/error/error-1.0.4.sh"

spec="debugSpec"
module  "$spec" "$base/development/debug/spec/debug-1.0.spec.sh"
runTest "$spec" "$base/development/debug/debug-1.0.0.sh"

spec="assertEqualSpec"
module  "$spec" "$base/development/spec-test/assert/equal/spec/assert-equal.spec.sh"
runTest "$spec" "$base/development/spec-test/assert/equal/assert-equal-0.9.8.sh"

spec="assertReturnCodeSpec"
module  "$spec" "$base/development/spec-test/assert/return-code/spec/assert-return-code-0.9.spec.sh"
runTest "$spec" "$base/development/spec-test/assert/return-code/assert-return-code-0.9.5.sh"

spec="helloWorldSpec"
module  "$spec" "$base/misc/hello-world/spec/hello-world.spec.sh"
runTest "$spec" "$base/misc/hello-world/hello-world-1.0.1.sh"

# module.sh parts

spec="colonConfigEvaluatedSpec"
module  "$spec" "$base/config/colon/colon-config-evaluated/spec/colon-config-evaluated-0.9.spec.sh"
runTest "$spec" "$base/config/colon/colon-config-evaluated/colon-config-evaluated-0.9.8.sh"

spec="httpsGetSpec"
module  "$spec" "$base/network/https-get/spec/https-get-1.0.spec.sh"
runTest "$spec" "$base/network/https-get/https-get-1.0.7.sh"

spec="tmpDirByUserKeywordSpec"
module  "$spec" "$base/development/polyfill/tmp-dir-by-user-keyword/spec/tmp-dir-by-user-keyword-0.9.spec.sh"
runTest "$spec" "$base/development/polyfill/tmp-dir-by-user-keyword/tmp-dir-by-user-keyword-0.9.5.sh"

spec="cacheSpec"
module  "$spec" "$base/development/cache/spec/cache-0.9.spec.sh"
runTest "$spec" "$base/development/cache/cache-0.9.7.sh"

spec="whitespaceProtectionSpec"
module  "$spec" "$base/content/transformer/whitespace-protection/spec/whitespace-protection-0.9.spec.sh"
runTest "$spec" "$base/content/transformer/whitespace-protection/whitespace-protection-0.9.2.sh"

spec="moduleFetchSpec"
module  "$spec" "$base/development/module/fetch/spec/module-fetch-0.9.spec.sh"
runTest "$spec" "$base/development/module/fetch/module-fetch-0.9.22.sh"

spec="moduleScopeSpec"
module  "$spec" "$base/development/module/scope/spec/module-scope-0.9.spec.sh"
runTest "$spec" "$base/development/module/scope/module-scope-0.9.4.sh"

spec="moduleChecksumSpec"
module  "$spec" "$base/development/module/checksum/spec/module-checksum-1.0.spec.sh"
runTest "$spec" "$base/development/module/checksum/module-checksum-1.0.0.sh"

spec="moduleValidateSpec"
module  "$spec" "$base/development/module/validate/spec/module-validate-0.9.spec.sh"
runTest "$spec" "$base/development/module/validate/module-validate-0.9.9.sh"

spec="moduleCoreSpec"
module  "$spec" "$base/development/module/core/spec/module-core-0.9.spec.sh"
runTest "$spec" "$base/development/module/core/module-core-0.9.22.sh"

#spec="Spec"
#module  "$spec" "$base/"
#runTest "$spec" "$base/"

printf 'All tests successful\n'
clearCache
