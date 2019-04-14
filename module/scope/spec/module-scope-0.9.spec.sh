#!/bin/sh

implementation="$1"
directory="$2"

module "moduleScope" "$implementation"
module "assertEqual" "https://mdl.sh/spec-test/assert/equal/assert-equal-0.9.5.sh" "cksum-566303087"

DEBUG_NAMESPACE="MODULE_SCOPE_SPEC"

# normal test
content="$(printf '#!/bin/sh\nprintf "test"\n')"
result="$(moduleScope "name" "$content")"
target="$(printf 'name() { (\nset -eu\n%s\n) }\n' "$content")"
assertEqual "Basic Module Scope" "$result" "$target"

# whitespace test
content="$(printf '#!/bin/sh\n\tprintf "test"\n')"
result="$(moduleScope "name" "$content")"
target="$(printf 'name() { (\nset -eu\n%s\n) }\n' "$content")"
assertEqual "Module Scope with whitespace" "$result" "$target"

# name test
content="$(printf '#!/bin/sh\n\tprintf "test"\n')"
result="$(moduleScope "noname" "$content")"
target="$(printf 'noname() { (\nset -eu\n%s\n) }\n' "$content")"
assertEqual "Module Scope different name" "$result" "$target"

# no sub-shell
content="$(printf '#!/bin/sh\n# guarantees: intentional-side-effects\nprintf "test"\n')"
result="$(moduleScope "name" "$content")"
target="$(printf 'name() {\n%s\n}\n' "$content")"
assertEqual "Module Scope without sub-shell" "$result" "$target"

# no sub-shell, with additional comments
content="$(printf '#!/bin/sh\n# Comment\n#\n# guarantees: intentional-side-effects\nprintf "test"\n')"
result="$(moduleScope "name" "$content")"
target="$(printf 'name() {\n%s\n}\n' "$content")"
assertEqual "Module Scope without sub-shell and more comments" "$result" "$target"

# invalid no sub-shell promise
content="$(printf '#!/bin/sh\n\n# guarantees: intentional-side-effects\nprintf "test"\n')"
result="$(moduleScope "name" "$content")"
target="$(printf 'name() { (\nset -eu\n%s\n) }\n' "$content")"
assertEqual "Module Scope with invalid no sub-shell promise" "$result" "$target"

# invalid no sub-shell promise2
content="$(printf '#!/bin/sh\nprintf "nothing"\n# guarantees: intentional-side-effects\nprintf "test"\n')"
result="$(moduleScope "name" "$content")"
target="$(printf 'name() { (\nset -eu\n%s\n) }\n' "$content")"
assertEqual "Module Scope with invalid no sub-shell promise2" "$result" "$target"
