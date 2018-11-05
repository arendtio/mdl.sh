#!/bin/sh
# This module tries to replicate the sh_quote behaivor of `printf '%q ' "$@"` for data without new lines
# to offer a POSIX compliant alternative
# inspired by https://stackoverflow.com/questions/12162010/posix-sh-equivalent-for-bash-s-printf-q
case $# in 0) return 0; esac
while :
do
	# take a look at http://git.savannah.gnu.org/gitweb/?p=bash.git;a=blob;f=lib/sh/shquote.c#l337
	printf '%s' "$1" | sed -e 's/\([][ \t\r\\"|\&;()<>\!\{\}\*\?\^\$`'\'']\)/\\\1/g' -e 's/[^=:]~/\\~/g'
	shift
	printf ' ' # to exactly replicate the output of `printf '%q ' "$@"` we print the space before the break
	case $# in 0) break; esac
done
printf '\n'
