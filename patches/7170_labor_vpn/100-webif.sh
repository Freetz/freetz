[ "$DS_TYPE_LANG_DE" == "y" ] || return 0
echo1 "Applying symlinks, deleting additional webinterfaces"
mv ${FILESYSTEM_MOD_DIR}/usr/www/avm ${FILESYSTEM_MOD_DIR}/usr/www/all
oems="avm 1und1 freenet"
for i in $oems; do
	rm -rf ${FILESYSTEM_MOD_DIR}/usr/www/$i
	ln -s all ${FILESYSTEM_MOD_DIR}/usr/www/$i
done

