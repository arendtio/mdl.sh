#!/bin/sh

module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "moduleFetch" "https://mdl.sh/development/module/fetch/module-fetch-0.9.21.sh" "cksum-2848792046"
module "moduleScope" "https://mdl.sh/development/module/scope/module-scope-0.9.4.sh" "cksum-4293153131"
module "moduleValidate" "https://mdl.sh/development/module/validate/module-validate-0.9.9.sh" "cksum-3271719601"

compile() {
	srcString="$1"
	relativeBasePath="$2"

	# the pipe creates a sub-shell but that it not relevant here
	printf '%s' "$srcString" | while IFS="" read -r p || [ -n "$p" ]
	do
		# if we find a 'module "name" "url"' line
		moduleSyntaxRegex='^[[:space:]]*module\(Local\)*[[:space:]][^"'\'']*["'\'']\([^"'\'']*\)["'\''] ["'\'']\([^"'\'']*\)["'\''][[:space:]]*["'\'']*\([^"'\'']*\)["'\'']*$'
		if printf '%s\n' "$p" | grep "$moduleSyntaxRegex" >/dev/null; then
			func="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\2;")"
			url="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\3;")"
			checksum="$(printf '%s\n' "$p" | sed "s;$moduleSyntaxRegex;\\4;")"
			scopeFlag="$(printf '%s\n' "$p" | sed 's;^[[:space:]]*module\(Local\)*[[:space:]]\{1,\}-s[[:space:]]\{1,\}.*$;true;')"

			printf 'processing %s\n' "$url" >&2

			#fetch and compile the target file
			printf '# start module %s\n' "$url"
			nextRelativeBase="/.." # a reasonable invalid path
			if [ "$(printf '%s' "$url" | head -c 8 | tr '[:upper:]' '[:lower:]')" = "https://" ]; then
				# TODO: module-core has a similar part, this should probably use whitespace-protect instead and module-validate should use stdin
				# maybe this critical part can be put into one module
				src="$(printf 'AAA'; moduleFetch "$url"; printf 'ZZZ')"
				src="${src#AAA}" # Protecting the whitespace
				src="${src%ZZZ}"
			elif [ "$(printf '%s' "$url" | head -c 1)" = "/" ]; then
				src="$(cat "$url")"
				nextRelativeBase="$(dirname "$url")"
			else
				src="$(cat "$relativeBasePath/$url")"
				nextRelativeBase="$(cd -P -- "$(dirname "$relativeBasePath/$url")" && pwd -P)"
			fi

			# validate checksum of src
			if [ "$checksum" != "" ]; then
				if ! moduleValidate "$src" "$checksum"; then
					error "Source code validation for $url failed. Checksum should be '$checksum'. Exiting."
					exit 1
				fi
			fi

			# recursive call of this compiler
			src="$(compile "$src" "$nextRelativeBase")"
			# remove shebang and first empty line
			src="$(printf '%s' "$src" | awk '!f && /^#!\// {f=1;next}1' | awk '{if (NR==1 && NF==0) next};1')"

			# wrap module in a subshell
			if [ "$scopeFlag" = "true" ]; then
				printf '%s\n' "$src" # if -s is present
			else
				moduleScope "$func" "$src"
			fi
			printf '# end module %s\n' "$url"

		# if we find a "fetch modul.sh via curl line", remove it (the compiler should do what modul.sh does)
		elif printf '%s\n' "$p" | grep "^[[:space:]]*eval .*mdl.sh.*/latest.*" >/dev/null; then
			printf ''
		elif printf '%s\n' "$p" | grep "^[[:space:]]*eval \"\$(curl -fsL [\"']https://[^\"']*/development/module/online/module-[^\"']*.sh[\"'])\"" >/dev/null; then
			printf ''
		else
			printf '%s\n' "$p"
		fi
	done
}

compile "$@"
