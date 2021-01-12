#!/bin/sh


# check number of arguments
if [ "$#" -ne 1 ]; then
	printf 'Invalid number of arguments\n' >&2
	exit 64
fi

module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "debug" "https://mdl.sh/development/debug/debug-1.0.0.sh" "cksum-1996092554"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.22.sh" "cksum-1242620769"
module "moduleScope" "https://mdl.sh/development/module/scope/module-scope-0.9.4.sh" "cksum-4293153131"
module "moduleValidate" "https://mdl.sh/development/module/validate/module-validate-0.9.9.sh" "cksum-3271719601"

export DEBUG_NAMESPACE="MODULE_COMPILER"

compile() {
	srcString="$1"

	if [ "$(printf '%s' "$srcString" | head -c3)" != '#!/' ]; then
		error "No shebang found" 65
	fi

	# the pipe creates a sub-shell but that it not relevant here
	printf '%s' "$srcString" | while IFS="" read -r p || [ -n "$p" ]
	do
		# if we find a 'module "name" "url"' line
		moduleSyntaxRegex='^[[:space:]]*module[[:space:]][^"'\'']*["'\'']\([^"'\'']*\)["'\''][[:space:]]\{1,\}["'\'']\([^"'\'']*\)["'\''][[:space:]]*["'\'']*\([^"'\'']*\)["'\'']*[[:space:]]*$'
		if printf '%s\n' "$p" | grep "$moduleSyntaxRegex" >/dev/null; then
			func="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\1;")"
			url="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\2;")"
			checksum="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\3;")"

			debug "$(printf 'processing %s\n' "$url")" 1

			#fetch and compile the target file
			printf '# start module %s\n' "$url"
			nextRelativeBase="/.." # a reasonable invalid path
			if [ "$(printf '%s' "$url" | head -c 8 | tr '[:upper:]' '[:lower:]')" = "https://" ]; then
				# TODO: module-core has a similar part, this should probably use whitespace-protect instead and module-validate should use stdin
				# maybe this critical part can be put into one module
				src="$(printf 'AAA'; moduleFetch "$url"; printf 'ZZZ')"
				src="${src#AAA}" # Protecting the whitespace
				src="${src%ZZZ}"
			fi

			# validate checksum of src
			if [ "$checksum" != "" ]; then
				if ! moduleValidate "$src" "$checksum"; then
					error "Source code validation for $url failed. Checksum should be '$checksum'. Exiting." 65
				fi
			fi

			# recursive call of this compiler
			src="$(compile "$src" "$nextRelativeBase")"
			# remove shebang and first empty line
			src="$(printf '%s' "$src" | awk '!f && /^#!\// {f=1;next}1' | awk '{if (NR==1 && NF==0) next};1')"

			# wrap module in a subshell
			moduleScope "$func" "$src"
			printf '# end module %s\n' "$url"

		elif printf '%s\n' "$p" | grep "eval[[:space:]].*mdl.sh.*latest.*" >/dev/null; then
			# if module.sh bootstrapping lines is being found for the 'latest' version
			printf ''
		elif printf '%s\n' "$p" | grep "eval[[:space:]].*mdl.sh/development/module/online/module-[^\"']*.sh" >/dev/null; then
			# if a specific module.sh version is being used
			printf ''
		else
			printf '%s\n' "$p"
		fi
	done
}

compile "$1"
