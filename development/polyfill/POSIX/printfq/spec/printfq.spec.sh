#!/bin/sh

implementation="$1"

module "printfq" "$implementation"
module "assertEqual" "https://mdl.sh/development/spec-test/assert/equal/assert-equal-0.9.7.sh" "cksum-3783051722"

testString1="echo 'asd (asd)'; echo \"\$asd\"\\na=\"a\"\\nb=\"b\" # different\\nif [ \"\$a\" != \"\$b\" ]; then\\n\tprintf '%s %s\\n' \"\$a\" \"\$b\" > /dev/null\\nfi\\n"
result="$(printfq "$testString1")"
target="$(cat << "EOF"
echo\ \'asd\ \(asd\)\'\;\ echo\ \"\$asd\"\\na=\"a\"\\nb=\"b\"\ #\ different\\nif\ \[\ \"\$a\"\ \!=\ \"\$b\"\ \]\;\ then\\n\\tprintf\ \'%s\ %s\\n\'\ \"\$a\"\ \"\$b\"\ \>\ /dev/null\\nfi\\n 
EOF
)"

assertEqual "Basic" "$result" "$target"

# testString1 does not contain newlines.
# printf uses $'' ANSI C quotes if newlines are present
# which in turn are not POSIX compatible
# so as long as no newlines are present we seem to create the same result

# currently, there is not support for multiline strings
#testString2="$(cat << "EOF"
#echo 'asd (asd)'; echo "\$asd"
#a="a"
#b="b" # different
#if [ "$a" != "$b" ]; then
#	printf '%s %s\n' "$a" "$b" > /dev/null
#fi
#EOF
#)"
