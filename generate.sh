#!/bin/bash
# generates everything
MYPWD="$(dirname $(realpath $0))"

echo -e "\nConfig:"
"$MYPWD/config/generate.sh"

echo -e "\nBusyBox:"
"$MYPWD/make/busybox/generate.sh"

echo -e "\nScreenshots:"
"$MYPWD/docs/screenshots/generate.sh"

echo -e "\nPackages:"
"$MYPWD/make/generate.sh" 2>&1 | grep -v '^nohelp'

echo -e "\nLibraries"
"$MYPWD/make/libs/generate.sh" 2>&1 | grep -v '^nohelp'

echo -e "\nPatches:"
"$MYPWD/patches/generate.sh" 2>&1 | grep -v '^nohelp'

echo

