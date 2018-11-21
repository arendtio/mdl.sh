#!/bin/sh
# TODO: add support for (non-numeric) extensions https://semver.org/#spec-item-9

if [ "$#" -ne 3 ]; then
	printf 'Not enough arguments\n'
	exit 127
fi


# mandatory:
versionA="$1"
operator="$2"
versionB="$3"

# returns 0 if the 2nd argument is a greater version than the first
# otherwise if returns 1 (less or equal)
isLess() {
	a="${1#\.}" # remove leading dots
	b="${2#\.}"

	if [ "$a" = "$b" ]; then
		return 1
	fi

	if [ "$a" = "" ]; then
		a1=0
	else
		a1="$(echo $a | awk -F '.' '{print $1}')"
	fi

	if [ "$b" = "" ]; then
		b1=0
	else
		b1="$(echo $b | awk -F '.' '{print $1}')"
	fi

	if [ "$a1" -lt "$b1" ]; then
		return 0
	elif [ "$a1" -gt "$b1" ]; then
		return 1
	else
		# remove leading digits
		isLess "${a#[^.]*}" "${b#[^.]*}"
		return $?
	fi
}

if [ "$operator" = "isLess" ]; then
	isLess "$versionA" "$versionB"
	exit $?
elif [ "$operator" = "isGreater" ]; then
	# switched order
	isLess "$versionB" "$versionA"
	exit $?
elif [ "$operator" = "isEqual" ]; then
	if ! isLess "$versionA" "$versionB" && ! isLess "$versionB" "$versionA"; then
		exit 0
	else
		exit 1
	fi
else
	printf 'No valid operator "%s".' "$operator"
	exit 127
fi
