#!/bin/sh

module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "moduleFetch" "https://mdl.sh/module/module-fetch-0.9.14.sh" "cksum-626475234"
module "moduleScope" "https://mdl.sh/module/scope/module-scope-0.9.3.sh" "cksum-424520902"
module "moduleValidate" "https://mdl.sh/module/validate/module-validate-0.9.5.sh" "cksum-550402517"

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
			if [ "$(printf '%s' "$url" | head -c 5 | tr '[:upper:]' '[:lower:]')" = "https" ]; then
				src="$(moduleFetch "$url")"
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
					error "Source code validation for $url failed. Exiting."
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
		elif printf '%s\n' "$p" | grep "^[[:space:]]*eval \"\$(curl -fsL [\"']https://[^\"']*/module/module-[^\"']*.sh[\"'])\"" >/dev/null; then
			printf ''
		elif printf '%s\n' "$p" | grep "^[[:space:]]*eval \".*/module-local/module-local-[^\"']*.sh.*\"" >/dev/null; then
			printf ''
		else
			printf '%s\n' "$p"
		fi
	done
}

compile "$@"