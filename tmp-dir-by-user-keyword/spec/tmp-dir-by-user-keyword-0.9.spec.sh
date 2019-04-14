#!/bin/sh

implementation="$1"

module "tmpDirByUserKeyword" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh" "cksum-1059380841"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.5.sh" "cksum-566303087"

# shellcheck disable=SC2034  # The debug module uses this variable
DEBUG_NAMESPACE="TMPDIR_SPEC"

# no argument
if tmpDirByUserKeyword >/dev/null 2>&1; then
	error "TEST: tmpDirByUserKeyword does not return a non-zero value if no argument is given"
fi

# normal usage
keyword1="spec-test"
result1=""
rc="0"
result1="$(tmpDirByUserKeyword "$keyword1")" || rc="$?" && true
target="0"
assertEqual "Return code" "$rc" "$target"
if [ ! -d "$result1" ]; then
	error "TEST: the directory returned by tmpDirByUserKeyword does not exist"
fi

if ! printf 'test\n' >"$result1/tmp.test"; then
	error "TEST: the directory returned by tmpDirByUserKeyword is not writable"
fi

# call it a 2nd time with the same keyword (should result in the same directory)
result2=""
result2="$(tmpDirByUserKeyword "$keyword1")" || rc="$?" && true
target="$result1"
assertEqual "Second call" "$result2" "$target"

# call it a with a different keyword (should result in a new directory)
keyword3="spec-test-other"
result3=""
result3="$(tmpDirByUserKeyword "$keyword3")" || rc="$?" && true
if [ "$result1" = "$result3" ]; then
	error "TEST: tmpDirByUserKeyword returned the same direcoty for different keywords"
fi

# cleanup
debug "$(rm -vr "$result1")" 1
debug "$(rm -vr "$result3")" 1
corePath1="$(printf '%s' "$result1" | sed 's/\.[^\./]*$//')"
debug "$(rm -v "$corePath1-pointer."*)" 1
corePath3="$(printf '%s' "$result3" | sed 's/\.[^\./]*$//')"
debug "$(rm -v "$corePath3-pointer."*)" 1
