#!/bin/bash

rm_files()
{
	for file in $1; do
	echo2 "$file"
	rm -rf "$file"
	done
}

[ "$DS_REMOVE_VOIP_ISDN" == "y" ] || return 0

echo1 "removing VoIP & ISDN files"
rm_files "$(find ${FILESYSTEM_MOD_DIR} -name '*iglet*' -o -name '*voip*' -o -name '*isdn*' -o -name '*ubik*' -o -name '*tiatm*' -o -name '*capi*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/')"
rm_files "$(find ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr -name 'libfon*' -o -name 'libtelcfg*')"
