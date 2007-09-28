#!/bin/bash -x

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

if [ "$DS_REMOVE_USERMAN" == "y" ]; then
    echo1 "removing userman files"
    rm -f "${FILESYSTEM_MOD_DIR}/bin/usermand"
    rm_files "$(find ${FILESYSTEM_MOD_DIR}/lib/modules -name userman)"
    rm_files "$(find ${HTML_LANG_MOD_DIR} -name 'userlist*' -o -name 'useradd*')"
    sed -i -e "s/KIDS=y/KIDS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/remove_userman.patch"
fi