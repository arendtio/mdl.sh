# Debug

This module provides an easy to use function to output debug
information to stderr when desired.

## Version 1.0 Usage

```
debug message [level] [section]
```

The easiest way to use it is to just call it with the mandatory
message:

```
debug "Here I am."
```

In addition, the function has two optional, positional parameters:

1. The level
2. The section

The idea is that when you have a script full of debugging messages
you might not want to turn all on at once.

So with the level you can later control the verbosity of your
debugging output. For example if you want to output level 2 debugg
messages, it will output all level 1 and level 2 messages, but not
level 3 messages. If no level is given, level 1 will be assumed. If
0 is given as a level the message will always be printed.

To make the output even more specific you can choose to output
messages from a certain section only. If you don't want to keep
writing the section for every message you can also use the
environment variable DEBUG_NAMESPACE.

To let the debug function print something you can set the desired
level either for all section or section specific:

```
DEBUG_ALL=1
DEBUG_MY_SECTION=3
```

## Examples

The following example should illustrate the functionality. Lets
assume we have a script `script.sh`:

```
#!/bin/sh

eval "$(curl -fsL 'https://mdl.sh/latest')"
module "debug" "https://mdl.sh/debug/debug-1.0.0.sh"

# section ALL by default
# level 1 by default
debug "One"
debug "Two" 2
debug "Three" 3

# changing the default section to MY_SECTION by setting the environment variable
DEBUG_NAMESPACE="MY_SECTION"
debug "A" 1
debug "B" 2
debug "C" 3

# explicitly using a section
debug "Another 1" 1 ANOTHER_SECTION
debug "Another 2" 2 ANOTHER_SECTION
debug "Another 3" 3 ANOTHER_SECTION
```

Calling it like `DEBUG_MY_SECTION=2 ./script.sh` would produce the
following output:

```
MY_SECTION: A
MY_SECTION: B
```

If the same Script is started via `DEBUG_ALL=2 ./script.sh` at the
end the output would be (with some module.sh debugging output before
it):

```
ALL: One
ALL: Two
MY_SECTION: A
MY_SECTION: B
ANOTHER_SECTION: Another 1
ANOTHER_SECTION: Another 2
```

# Development Notes

In order to reduce the performance penalty of the debug function,
the code uses the `intentional-side-effects` directive. As a result
he code is kinda hard to read/understand.

To make it easier to understand the following code give some
historic hints:

```
# Examples
# Printing the debug message every time the function is called:
# debug "Executing this section" 0
#
# Print the debug message only when at least one of DEBUG_ALL or DEBUG_MYSEC is set to a number larger or equal to 2
# debug "Executing this section" 2 "MYSEC"

## mandatory:
## error message
#msg="$1"
#
## optional:
## debug level when the message should be displayed
#level="${2:-1}"
## debug section
#section="${3:-ALL}"
#section="${3:-${DEBUG_NAMESPACE:-ALL}}"
#
#envDebugLevel="$(printf '%s' "${DEBUG_ALL:-0}")"
#envDebugSectionLevel="$(eval "printf '%s\\n' \"\${DEBUG_$section:-$envDebugLevel}\"")"
#if [ "$envDebugSectionLevel" -ge "$level" ]; then
#	printf '%s: %s\n' "$section" "$msg" >&2
#fi
```

