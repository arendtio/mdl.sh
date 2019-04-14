#!/bin/sh

implementation="$1"

module "semverCompare" "$implementation"
module "error" "https://mdl.sh/error/error-1.0.3.sh" "cksum-2734170982"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.6.sh" "cksum-2671631268"

# too few arguments
if semverCompare >/dev/null 2>&1; then
	error "TEST: semverCompare does not return a non-zero value if not enough arguments (0 of 3) are supplied" 1
fi
if semverCompare "1" >/dev/null 2>&1; then
	error "TEST: semverCompare does not return a non-zero value if not enough arguments (1 of 3) are supplied" 1
fi
if semverCompare "1" "2" >/dev/null 2>&1; then
	error "TEST: semverCompare does not return a non-zero value if not enough arguments (2 of 3) are supplied" 1
fi

# invalid operator
if semverCompare "1.0.0" "noop" "2.0.0" >/dev/null 2>&1; then
	error "TEST: semverCompare does not return a non-zero value if an invalid operator is used" 1
fi

# mind the 4th parameter
compareTest() {
	result="0"
	semverCompare "$1" "$2" "$3" || result="$?" && true
	target="$4"
	assertEqual "$1 $2 $3" "$result" "$target"
	return $?
}

# compare isEqual
compareTest 1.0.0 isEqual 1.0.0 0
compareTest 1.1.0 isEqual 1.1.0 0
compareTest 1.2.3 isEqual 1.2.3 0
compareTest 1.0 isEqual 1.0.0 0
compareTest 1 isEqual 1.0.0 0

# not equal examples
compareTest 1.0.0 isEqual 1.0.1 1
compareTest 1.0.0 isEqual 1.0.2 1
compareTest 1.0.0 isEqual 1.1.0 1
compareTest 1.0.0 isEqual 1.1.0 1
compareTest 1.0.0 isEqual 2.0.0 1

# compare isLess
compareTest 1.0.0 isLess 1.0.1 0
compareTest 1.0.0 isLess 1.1.0 0
compareTest 1.0.0 isLess 1.1.1 0
compareTest 1.0.0 isLess 2.1.1 0
compareTest 2.2.2 isLess 3.1.1 0
compareTest 1.2.2 isLess 1.4.1 0
compareTest 1.1.2 isLess 1.1.3 0
# same with inverse result
compareTest 1.0.1 isLess 1.0.0 1
compareTest 1.1.0 isLess 1.0.0 1
compareTest 1.1.1 isLess 1.0.0 1
compareTest 2.1.1 isLess 1.0.0 1
compareTest 3.1.1 isLess 2.2.2 1
compareTest 1.4.1 isLess 1.2.2 1
compareTest 1.1.3 isLess 1.1.2 1

# compare isGreater
compareTest 1.0.1 isGreater 1.0.0 0
compareTest 1.1.0 isGreater 1.0.0 0
compareTest 1.1.1 isGreater 1.0.0 0
compareTest 2.1.1 isGreater 1.0.0 0
compareTest 3.1.1 isGreater 2.2.2 0
compareTest 1.4.1 isGreater 1.2.2 0
compareTest 1.1.3 isGreater 1.1.2 0
# same with inverse result
compareTest 1.0.0 isGreater 1.0.1 1
compareTest 1.0.0 isGreater 1.1.0 1
compareTest 1.0.0 isGreater 1.1.1 1
compareTest 1.0.0 isGreater 2.1.1 1
compareTest 2.2.2 isGreater 3.1.1 1
compareTest 1.2.2 isGreater 1.4.1 1
compareTest 1.1.2 isGreater 1.1.3 1

# equal cases for isLess and isGreater
compareTest 1.0.0 isLess 1.0.0 1
compareTest 1.0 isLess 1.0.0 1
compareTest 1.0.0 isGreater 1.0.0 1
compareTest 1.0 isGreater 1.0.0 1
