#!/bin/bash

DEFAULTSET="ansi gnome konsole linux putty rxvt screen screen-w sun vt100 vt102 vt102-nsgr vt102-w vt200 vt220 vt52 xterm xterm-color xterm-xfree86"

cat <<"EOF"
### script-generated file; do not change manually ###

menu "terminfo database"

comment "Select terminfo database entries to install (see help of 'Show all items')"

config FREETZ_SHARE_terminfo
	bool "terminfo database"
	default n

config FREETZ_SHARE_terminfo_showall
	bool "Show all items"
	depends on FREETZ_SHARE_terminfo
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
	ID="$(echo "$FILE" | sed -e 's/\./DOT/g' -e 's/-/MINUS/g' -e 's/\+/PLUS/g')"

	# check link
	if [ -L "$O" ]; then
		TARGET_O="$(basename `readlink $O`)"
		TARGET_DIR="$(dirname $TARGET_O)"
		TARGET_FILE="$(basename $TARGET_O)"

		TARGET_ID="$(echo "$TARGET_FILE" | sed -e 's/\./DOT/g' -e 's/-/MINUS/g' -e 's/\+/PLUS/g')"
	else
		TARGET_ID=""
	fi
	
	
	SIZE="$(du -b "$O" | awk '{print $1}')"
	DEFAULT="$(for I in $DEFAULTSET; do [ "$I" = "$FILE" ] && echo "y"; done)"
	[ -z "$DEFAULT" ] && DEFAULT="n"

	echo "config FREETZ_SHARE_terminfo_$ID"
	echo "	bool \"$FILE ($SIZE Bytes)\""
	
	if [ "$DEFAULT" = "y" ]; then
		echo "	depends on FREETZ_SHARE_terminfo"
	else
		echo "	depends on FREETZ_SHARE_terminfo_showall"
	fi

	if [ -n "$TARGET_ID" ]; then
		echo "	select FREETZ_SHARE_terminfo_${TARGET_ID}"
	fi

	echo "	default $DEFAULT"
	echo ""
done

echo "endmenu"
