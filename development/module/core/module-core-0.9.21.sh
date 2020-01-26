#!/bin/sh
# guarantees: intentional-side-effects

# we need to eval the module code here to make sure the function is
# defined in the current scope
eval "$(
	# generate src
	src="$(
		set -eu

		module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
		module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.21.sh" "cksum-2848792046"
		module "moduleScope" "https://mdl.sh/development/module/scope/module-scope-0.9.4.sh" "cksum-4293153131"
		module "moduleValidate" "https://mdl.sh/development/module/validate/module-validate-0.9.9.sh" "cksum-3271719601"

		# set other parameters
		name="$1"
		location="$2"
		# optional, but recommended:
		checksum="${3:-}"

		# check for POSIX compliant function name
		# https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_235
		if ! expr "$name" : '^[A-Z_a-z][0-9A-Z_a-z]*$' >/dev/null 2>&1; then
			error "The function name '$name' is invalid. Exiting." 65
		fi

		# obtain module source from https or a local repository
		src="$(printf 'AAA'; moduleFetch "$location"; rcs="$?"; printf 'ZZZ'; exit "$rcs")"
		rc="$?"
		src="${src#AAA}" # Protecting the whitespace
		src="${src%ZZZ}"
		if [ "$rc" != "0" ]; then
			error "The module content '$location' could not be loaded. Exiting." 69
		fi

		# validate source
		if [ "$#" -ge 3 ] && ! moduleValidate "$src" "$checksum"; then
			error "Validation of module '$location' has failed. Exiting." 65
		fi

		# add a separat scope (sub-shell) for every module
		# moduleScope detects if the module uses the
		# 'intentional-side-effects' directive to skip it
		src="$(moduleScope "$name" "$src")"
		printf '%s' "$src"
	)"
	rc="$?"

	# check if generating the src succeeded
	if [ "$rc" = "0" ]; then
		# if everything is fine the src will be passed to eval
		printf '%s' "$src"
	else
		# If generating the src failed the return code will be passed throught
		# eval as the return value of eval is the return value of the evaluated
		# expression. So we wrap an exti command into a subshell to return a
		# custom return code without exiting the script.
		printf '( exit %s )' "$rc"
	fi
)"
