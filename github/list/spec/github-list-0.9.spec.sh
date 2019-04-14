#!/bin/sh

implementation="$1"
directory="$2"

module "githubList" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-0.9.2.sh" "cksum-2374238394"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.5.sh" "cksum-566303087"

DEBUG_NAMESPACE="GITHUB_LIST_SPEC"

# no arguments
if githubList >/dev/null 2>&1; then
	error "TEST: githubList does not return a non-zero value if there are no arguments"
fi

# too few arguments
if githubList "files" >/dev/null 2>&1; then
	error "TEST: githubList does not return a non-zero value if there are too few arguments"
fi

# invalid action
if githubList "invalid" >/dev/null 2>&1; then
	error "TEST: githubList does not return a non-zero value if an invalid action is given"
fi

# action all
result="$(githubList "all" "arendtio" "mdl.sh" / | grep '^/\(CNAME\|hello-world\)$' | wc -l | sed 's/^[[:space:]]*//g')"
target="2"
assertEqual "Action all" "$result" "$target"

# action dirs
result="$(githubList "dirs" "arendtio" "mdl.sh" / | grep '^/hello-world$')"
target="/hello-world"
assertEqual "Action dirs" "$result" "$target"

# action files
result="$(githubList "files" "arendtio" "mdl.sh" / | grep '^/CNAME$')"
target="/CNAME"
assertEqual "Action files" "$result" "$target"

# with custom path
result="$(githubList "files" "arendtio" "mdl.sh" /hello-world | grep '^/hello-world/hello-world-1.0.0.sh$')"
target="/hello-world/hello-world-1.0.0.sh"
assertEqual "Custom path" "$result" "$target"

# with additional slash at the end of the path
result="$(githubList "files" "arendtio" "mdl.sh" /hello-world/ | grep '^/hello-world/hello-world-1.0.0.sh$')"
target="/hello-world/hello-world-1.0.0.sh"
assertEqual "Custom path with slash" "$result" "$target"

# fail if path doesn't start with a slash
if githubList "files" "arendtio" "mdl.sh" "hello-world" >/dev/null 2>&1; then
	error "TEST: githubList does not return a non-zero value if the path argument does not start with a slash"
fi
