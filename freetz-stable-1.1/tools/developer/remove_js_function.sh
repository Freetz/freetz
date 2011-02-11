#!/bin/bash

# Helper script for calling remove_js_function.awk
#
# Note: This is SLOW when used on many files because it cannot be done
# in place and preserves original files' access rights.

AWK_SCRIPT="$(dirname "$0")/remove_js_function.awk"
TMP_FILE="$(dirname "$1")/_$(basename "$1")_"

# Remove functions specified by regex pattern in $2
awk -f "$AWK_SCRIPT" -v fname=$2 "$1" > "$TMP_FILE"

# Move temp-file back to original place
access_rights=$(stat -c "%a" "$1")
mv "$TMP_FILE" "$1"
chmod $access_rights "$1"
