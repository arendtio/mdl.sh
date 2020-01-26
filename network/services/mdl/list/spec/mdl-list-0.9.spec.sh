#!/bin/sh

implementation="$1"

module "mdlList" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"

# no arguments
if mdlList >/dev/null 2>&1; then
	error "TEST: mdlList does not return a non-zero value if there are no arguments"
fi

# too few arguments
if mdlList "files" >/dev/null 2>&1; then
	error "TEST: mdlList does not return a non-zero value if there are too few arguments"
fi

# invalid action
if mdlList "invalid" >/dev/null 2>&1; then
	error "TEST: mdlList does not return a non-zero value if an invalid action is given"
fi

# action all
result="$(mdlList "all" / | grep -c '^/\(CNAME\|misc\)$' | sed 's/^[[:space:]]*//g')"
target="2"
assertEqual "Action all" "$result" "$target"

# action dirs
result="$(mdlList "dirs" / | grep '^/misc$')"
target="/misc"
assertEqual "Action dirs" "$result" "$target"

# action files
result="$(mdlList "files" / | grep '^/CNAME$')"
target="/CNAME"
assertEqual "Action files" "$result" "$target"

# with custom path
result="$(mdlList "files" /misc/hello-world | grep '^/misc/hello-world/hello-world-1.0.1.sh$')"
target="/misc/hello-world/hello-world-1.0.1.sh"
assertEqual "Custom path" "$result" "$target"

# with additional slash at the end of the path
result="$(mdlList "files" /misc/hello-world/ | grep '^/misc/hello-world/hello-world-1.0.1.sh$')"
target="/misc/hello-world/hello-world-1.0.1.sh"
assertEqual "Custom path with slash" "$result" "$target"

# fail if path doesn't start with a slash
if mdlList "files" "misc" >/dev/null 2>&1; then
	error "TEST: mdlList does not return a non-zero value if the path argument does not start with a slash"
fi

# list dirs in a directory without subdirs
result="$(mdlList "dirs" /misc/hello-world/spec)"
target=""
assertEqual "List dirs when no subdirs exist" "$result" "$target"
