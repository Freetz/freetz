#!/bin/bash

rm_files()
{
	for file in $1; do
	echo2 "$file"
	if [ -d "$file" ]; then
		rm -rf "$file"
	else
		rm -f "$file"
	fi
	done
}

if [ "$DS_REMOVE_DSLD" == "y" ]; then
	echo1 "removing dsld files"
	rm_files "$(find ${FILESYSTEM_MOD_DIR}/sbin -name '*dsld*')"
	rm_files "$(find ${FILESYSTEM_MOD_DIR}/lib/modules -name dsld)"
	sed -i -e "s/DSL=y/DSL=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
fi
