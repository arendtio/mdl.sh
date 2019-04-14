#!/bin/sh

implementation="$1"
# directory="$2"

module "findVersion" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "debug" "https://mdl.sh/debug/debug-0.9.2.sh" "cksum-2374238394"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.5.sh" "cksum-566303087"

DEBUG_NAMESPACE="FIND_VERSION_SPEC"
export DEBUG_NAMESPACE


# simple fails
# no arguments
if findVersion >/dev/null 2>&1; then
	error "TEST: findVersion does not return a non-zero value if no argument is given"
fi
# invalid action
if findVersion "makeMeASandwich" "Hamburger" >/dev/null 2>&1; then
	error "TEST: findVersion does not return a non-zero value if an invalid action is given"
fi


# name from path
## just a name
result="$(findVersion "nameFromPath" "/hello-1.2.3.sh")"
target="hello"
assertEqual "simple nameFromPath" "$result" "$target"

## with same name directory
result="$(findVersion "nameFromPath" "/hello/hello-1.2.3.sh")"
target="hello"
assertEqual "nameFromPath with same name dir" "$result" "$target"

## with different name directory
result="$(findVersion "nameFromPath" "/my/world/hello-1.2.3.sh")"
target="hello"
assertEqual "nameFromPath with different name dir" "$result" "$target"

## with dashes
result="$(findVersion "nameFromPath" "/my-world/hello-world-1.2.3.sh")"
target="hello-world"
assertEqual "nameFromPath with dashes" "$result" "$target"

## spec
result="$(findVersion "nameFromPath" "/my-world/hello-world.spec.sh")"
target="hello-world"
assertEqual "nameFromPath spec" "$result" "$target"

## spec with version condition
result="$(findVersion "nameFromPath" "/my-world/hello-world-3.spec.sh")"
target="hello-world"
assertEqual "nameFromPath spec with version X." "$result" "$target"

## spec with version condition 2
result="$(findVersion "nameFromPath" "/my-world/hello-world-3.2.spec.sh")"
target="hello-world"
assertEqual "nameFromPath spec with version X.X" "$result" "$target"


# version from path
## normal
result="$(findVersion "versionFromPath" "/hello-1.2.3.sh")"
target="1.2.3"
assertEqual "simple versionFromPath" "$result" "$target"

## with directory
result="$(findVersion "versionFromPath" "/hello/hello-1.2.3.sh")"
target="1.2.3"
assertEqual "versionFromPath with directory" "$result" "$target"

## with dashes
result="$(findVersion "versionFromPath" "/hello-world/hello-world-1.2.3.sh")"
target="1.2.3"
assertEqual "versionFromPath with dashes" "$result" "$target"

## spec (empty)
result="$(findVersion "versionFromPath" "/hello-world/spec/hello-world.spec.sh")"
target=""
assertEqual "versionFromPath spec" "$result" "$target"

## spec with version condition
result="$(findVersion "versionFromPath" "/hello-world/spec/hello-world-1.2.spec.sh")"
target=""
assertEqual "versionFromPath spec" "$result" "$target"


# major from version
## 0.0.0
result="$(findVersion "majorFromVersion" "0.0.0")"
target="0"
assertEqual "majorFromVersion 0.0.0" "$result" "$target"

## 1.0.0
result="$(findVersion "majorFromVersion" "1.0.0")"
target="1"
assertEqual "majorFromVersion 1.0.0" "$result" "$target"

## 2.3.4
result="$(findVersion "majorFromVersion" "2.3.4")"
target="2"
assertEqual "majorFromVersion 2.3.4" "$result" "$target"

## 1.0
result="$(findVersion "majorFromVersion" "1.0")"
target="1"
assertEqual "majorFromVersion 1.0" "$result" "$target"

## 1
result="$(findVersion "majorFromVersion" "1")"
target="1"
assertEqual "majorFromVersion 1" "$result" "$target"

## 100
result="$(findVersion "majorFromVersion" "100")"
target="100"
assertEqual "majorFromVersion 100" "$result" "$target"


# latestSameMajor
## hello world
result="$(findVersion "latestSameMajor" "/hello-world/hello-world-1.2.3.sh")"
target="/hello-world/hello-world-1.0.1.sh"
assertEqual "latestSameMajor hello-world" "$result" "$target"

## error-1.0.0
result="$(findVersion "latestSameMajor" "/error/error-1.0.0.sh")"
target="/error/error-1.0.3.sh"
assertEqual "latestSameMajor error-1.0.0" "$result" "$target"
