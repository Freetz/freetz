#!/bin/bash
# generates docs/PREREQUISITES/README.md
MDPWD="$(dirname $(realpath $0))"

cat "$MDPWD/template.md" > "$MDPWD/README.md"
for x in "$MDPWD/packages/"*.txt; do
	name="${x##*/}"
	vals="$(sed 's/[\t ]*#.*//g' $x | tr '\n' ' ' | sed 's/^ *//;s/ *$//g')"
	sed -i "s!%%${name%.txt}%%!${vals}!" "$MDPWD/README.md"
done

