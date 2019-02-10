#!/bin/sh

implementation="$1"
directory="$2"

module "mdlList" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"
module "debug" "https://mdl.sh/debug/debug-0.9.1.sh" "cksum-2534568300"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.2.sh" "cksum-1669532880"

DEBUG_NAMESPACE="MDL_LIST_SPEC"

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
result="$(mdlList "all" / | grep '^/\(CNAME\|hello-world\)$' | wc -l | sed 's/^[[:space:]]*//g')"
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
