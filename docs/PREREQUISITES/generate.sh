#!/bin/bash
# generates docs/PREREQUISITES/README.md
MDPWD="$(dirname $(realpath $0))"

cat "$MDPWD/template.md" > "$MDPWD/README.md"
for x in "$MDPWD/packages/"*; do
	vals="$(sed 's/[\t ]*#.*//g' $x | sort | tr '\n' ' ' | sed 's/^ *//;s/  */ /g;s/ *$//g')"
	sed -i "s!%%${x##*/}%%!${vals}!" "$MDPWD/README.md"
done

