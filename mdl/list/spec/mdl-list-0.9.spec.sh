#!/bin/sh

implementation="$1"

module "mdlList" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.6.sh" "cksum-2671631268"

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
result="$(mdlList "all" / | grep -c '^/\(CNAME\|hello-world\)$' | sed 's/^[[:space:]]*//g')"
target="2"
assertEqual "Action all" "$result" "$target"

# action dirs
result="$(mdlList "dirs" / | grep '^/hello-world$')"
target="/hello-world"
assertEqual "Action dirs" "$result" "$target"

# action files
result="$(mdlList "files" / | grep '^/CNAME$')"
target="/CNAME"
assertEqual "Action files" "$result" "$target"

# with custom path
result="$(mdlList "files" /hello-world | grep '^/hello-world/hello-world-1.0.0.sh$')"
target="/hello-world/hello-world-1.0.0.sh"
assertEqual "Custom path" "$result" "$target"

# with additional slash at the end of the path
result="$(mdlList "files" /hello-world/ | grep '^/hello-world/hello-world-1.0.0.sh$')"
target="/hello-world/hello-world-1.0.0.sh"
assertEqual "Custom path with slash" "$result" "$target"

# fail if path doesn't start with a slash
if mdlList "files" "hello-world" >/dev/null 2>&1; then
	error "TEST: mdlList does not return a non-zero value if the path argument does not start with a slash"
fi

# list dirs in a directory without subdirs
result="$(mdlList "dirs" /hello-world/spec)"
target=""
assertEqual "List dirs when no subdirs exist" "$result" "$target"
