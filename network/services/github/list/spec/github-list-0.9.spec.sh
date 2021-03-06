#!/bin/sh

implementation="$1"

module "githubList" "$implementation"
module "error" "https://mdl.sh/development/error/error-1.0.4.sh" "cksum-1614978459"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"

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
result="$(githubList "all" "arendtio" "mdl.sh" / | grep -c '^/\(CNAME\|misc\)$' | sed 's/^[[:space:]]*//g')"
target="2"
assertEqual "Action all" "$result" "$target"

# action dirs
result="$(githubList "dirs" "arendtio" "mdl.sh" / | grep '^/misc$')"
target="/misc"
assertEqual "Action dirs" "$result" "$target"

# action files
result="$(githubList "files" "arendtio" "mdl.sh" / | grep '^/CNAME$')"
target="/CNAME"
assertEqual "Action files" "$result" "$target"

# with custom path
result="$(githubList "files" "arendtio" "mdl.sh" /misc/hello-world | grep '^/misc/hello-world/hello-world-1.0.1.sh$')"
target="/misc/hello-world/hello-world-1.0.1.sh"
assertEqual "Custom path" "$result" "$target"

# with additional slash at the end of the path
result="$(githubList "files" "arendtio" "mdl.sh" /misc/hello-world/ | grep '^/misc/hello-world/hello-world-1.0.1.sh$')"
target="/misc/hello-world/hello-world-1.0.1.sh"
assertEqual "Custom path with slash" "$result" "$target"

# fail if path doesn't start with a slash
if githubList "files" "arendtio" "mdl.sh" "misc" >/dev/null 2>&1; then
	error "TEST: githubList does not return a non-zero value if the path argument does not start with a slash"
fi
