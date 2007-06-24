#!/bin/bash

mod_base="."
fw_base="build/original/filesystem"
case $# in
	0)
		;;
	1)
		mod_base="$1"
		;;
	2)
		mod_base="$1"
		fw_base="$2"
		;;
	*)
		echo "usage: $0 [<ds-mod base directory> [<fw base directory>]]" >&2
		echo "    ds-mod base directory defaults to '.'" >&2
		echo "    fw base directory defaults to 'build/original/filesystem'" >&2
		exit 1
esac
files=$(find "$mod_base/$fw_base" -type f | xargs file | grep "ELF 32" | sed -e 's/: .*//' | grep -v -E '\.ko$')
for file in $files; do
	echo "$file"
	"$mod_base/toolchain/target/mipsel-linux-uclibc/bin/ldd" "$file" | sed -e 's/ =>.*//'
	echo "----------------------------------------------------------------------"
done
