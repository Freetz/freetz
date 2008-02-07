[ "$DS_TYPE_LANG_A_CH" == "y" ] || return 0
echo1 "Applying symlinks, deleting additional webinterfaces"
mv ${FILESYSTEM_MOD_DIR}/usr/www/avm ${FILESYSTEM_MOD_DIR}/usr/www/all
oems="$(grep 'for i in  avm' "${FIRMWARE_MOD_DIR}/var/install" | head -n 1 | sed -e 's/^.*for i in\(.*\); do.*$/\1/')"
for i in $oems; do
	rm -rf ${FILESYSTEM_MOD_DIR}/usr/www/$i
	ln -s all ${FILESYSTEM_MOD_DIR}/usr/www/$i
done


