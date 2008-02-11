#!/bin/bash

DEFAULTSET="ansi gnome konsole linux putty rxvt screen screen-w sun vt100 vt102 vt102-nsgr vt102-w vt200 vt220 vt52 xterm xterm-color xterm-xfree86"

cat <<"EOF"
### script-generated file; do not change manually ###

menu "terminfo database"

comment "Select terminfo database entries to install (see help of 'Show all items')"

config DS_LIB_libterminfo
	bool "terminfo database"
	default n

config DS_LIB_libterminfo_showall
	bool "Show all items"
	depends on DS_LIB_libterminfo
	default n
	help
		Terminfo is a library and database that enables programs to use display
		terminals in a device-independent manner. This allows external programs
		to be able to have character-based display output, independent of the
		type of terminal.

		The default selection for the Freetz should be sufficient for most
		cases. However, you can extend the selection to fit your own requirements.

EOF

for O in `find . -type f -o -type l | sort`; do
	DIR="$(dirname $O)"
	FILE="$(basename $O)"

	# config id
	ID="$(echo "$FILE" | sed -e 's/\./dot/g' -e 's/-/minus/g' -e 's/\+/plus/g')"

	# check link
	if [ -L "$O" ]; then
		TARGET_O="$(basename `readlink $O`)"
		TARGET_DIR="$(dirname $TARGET_O)"
		TARGET_FILE="$(basename $TARGET_O)"

		TARGET_ID="$(echo "$TARGET_FILE" | sed -e 's/\./dot/g' -e 's/-/minus/g' -e 's/\+/plus/g')"
	else
		TARGET_ID=""
	fi
	
	
	SIZE="$(du -b "$O" | awk '{print $1}')"
	DEFAULT="$(for I in $DEFAULTSET; do [ "$I" = "$FILE" ] && echo "y"; done)"
	[ -z "$DEFAULT" ] && DEFAULT="n"

	echo "config DS_LIB_libterminfo_$ID"
	echo "	bool \"$FILE ($SIZE Bytes)\""
	
	if [ "$DEFAULT" = "y" ]; then
		echo "	depends on DS_LIB_libterminfo"
	else
		echo "	depends on DS_LIB_libterminfo_showall"
	fi

	if [ -n "$TARGET_ID" ]; then
		echo "	select DS_LIB_libterminfo_${TARGET_ID}"
	fi

	echo "	default $DEFAULT"
	echo ""
done

echo "endmenu"
