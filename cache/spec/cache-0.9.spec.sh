#!/usr/bin/env bash
# cache.sh needs to be POSIX compatible for this test to be too
# cache requires md5sum :-/
##!/bin/sh

implementation="$1"
baseDirectory="$2"

module "cache" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.1.sh" "cksum-1107954660"
module "debug" "https://mdl.sh/debug/debug-0.9.1.sh" "cksum-2534568300"
module "assertEqual" "https://mdl.sh/spec-test/assert-equal-0.9.2.sh" "cksum-1669532880"

keyword="test-cache"
cacheDirectory="$baseDirectory/cacheTest"
mkdir -p "$cacheDirectory"

# check if the cache dir is empty
assertEqual "Empty cacheDir" "$(ls -A "$cacheDirectory")" ""

#
# Define an unstable function
#
# Note: The cache should only be used to cache stable functions
# (the return value is dependent on the arguments only)
# But for testing an unstable function can be helpful to find out
# if the result was obtained from the cache
value=1
returnVal=0
cmd="unstableFunc"
unstableFunc() {
	printf '%s\n' "$value"
	return $returnVal
}


#
# Test directory option (-d)
#
beforeCmdCount="$(ls -A "$cacheDirectory" | wc -l)"
cache -d "$cacheDirectory" -- printf 'explicit option' >/dev/null
assertEqual "Explicit directory option" "$(ls -A "$cacheDirectory" | wc -l)" "$((beforeCmdCount + 1))"

# use the env variable for the following tests
cacheDir="$cacheDirectory"
export cacheDir
beforeCmdCount="$(ls -A "$cacheDir" | wc -l)"
cache -- printf 'env cacheDir' >/dev/null
assertEqual "CacheDir from env" "$(ls -A "$cacheDir" | wc -l)" "$((beforeCmdCount + 1))"


#
# Syntax tests
#
# Double Dash Syntax (--)
result="$(cache -- printf 'hello')"
target="hello"
assertEqual "Double Dash syntax" "$result" "$target"

# Escaped semicolon syntax test
result="$(cache -- printf 'hello (foo)' \; printf 'bar')"
target="hello (foo)bar"
assertEqual "Semicolon syntax" "$result" "$target"

# string syntax test (-s)
result="$(cache -s "printf 'toge'; sleep 0; printf 'ther'")"
target="together"
assertEqual "String syntax" "$result" "$target"

# string syntax with additional parameters afterwards -s "ls" -t 2
keyCmd="printf 'string syntax with keydict'"
cache -s "$keyCmd" -k >/dev/null
if ! [ -e "$cacheDir/keyDict/"* ]; then
	error "TEST: String syntax with parameters afterwards failed" 1
fi
rm "$cacheDir/keyDict/"*

# invalid option (-X)
if cache -X -s "printf 'invalid option test'" >/dev/null 2>&1; then
	error "TEST: invalid cache.sh option did not trigger a fail (it should)" 1
fi


#
# Test Keydict
#
keyCmd="printf 'keyDict'"
cache -k -s "$keyCmd" >/dev/null
result="$(cat "$cacheDir/keyDict/"*)"
target="$keyCmd"
assertEqual "String syntax" "$result" "$target"
rm "$cacheDir/keyDict/"*

# keyDict for a cache element
keyCmd="printf 'keyDict cached'"
cache -s "$keyCmd" >/dev/null
cache -k -s "$keyCmd" >/dev/null
if ! [ -e "$cacheDir/keyDict/"* ]; then
	error "TEST: 'keyDict for a cached element' failed (did not create a keyDict)" 1
fi
result="$(cat "$cacheDir/keyDict/"*)"
target="$keyCmd"
assertEqual "String syntax" "$result" "$target"
rm "$cacheDir/keyDict/"*


#
# Test time limit (-t)
#
value=1
returnVal=0
cmd="unstableFunc"
# execute the command a first time
result1="$(cache -t 2 -s "$cmd")"
assertEqual "Time limit init" "$result1" "1"

# change value to detect cached values
value=2

# execute the command a second time
result2="$(cache -t 2 -s "$cmd")"
assertEqual "Time limit cached" "$result2" "$result1"

# wait until the cache expires
debug "Waiting 3 seconds until the cache is expired..." CACHE_SPEC 1
sleep 3

# execute the command a third time after the cache expired
result3="$(cache -t 2 -s "$cmd")"
assertEqual "Time limit expired cache" "$result3" "2"


#
# Test failing commands (non-zero return value)
#
# Fails should not be cached, so the function is executed every time
value=1
returnVal=1

# execute the function but do not return the output nor cache it due to its return value
result1="$(cache -- unstableFunc || true)"
assertEqual "Non-zero return init" "$result1" ""

# execute the same command again. This time with a non-error return value
value=2
returnVal=0
result2="$(cache -- unstableFunc || true)"
assertEqual "Return uncached" "$result2" "2"


#
# Content Tests
#
# content without newline
target="$(printf 'content without newline' | cksum)"
result="$(cache -s "printf 'content without newline'" | cksum)"
assertEqual "Content without newline" "$result" "$target"

# content with newline at the end
target="$(printf 'content with newline\n' | cksum)"
result="$(cache -s "printf 'content with newline\\n'" | cksum)"
assertEqual "Content with newline" "$result" "$target"


#
# Remove/reset cache (-r)
#
cache -r
if [ -d "$cacheDir" ]; then
	error "TEST: 'cache -r' did not remove the cache directory as it is supposed to" 1
fi


#
# TODO: Future work - aka 1.0
#
# - In the current version cache -r removes the cacheDir completely.
#   For version 1.0 we might consider changing it to removing just the content
#   of the directory.
# - no cacheDir (should respond with error, breaking change, simply creating the dir is bad practice (you never know what you might overwrite))
