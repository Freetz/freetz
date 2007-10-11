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
    if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	sed -i -e "s/KIDS=y/KIDS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
	if [ "$DS_HAS_WLAN" == "y" ]; then
	    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/remove_userman_wlan_old.patch"
	else
	    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/remove_userman_old.patch"
	fi
    else
	sed -i -e "s/CONFIG_KIDS=y/CONFIG_KIDS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
	if [ "$DS_HAS_WLAN" == "y" ]; then
	    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/remove_userman_wlan_new.patch"
        else
	    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/remove_userman_new.patch"
        fi
    fi
fi
