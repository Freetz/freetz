[ "$FREETZ_REMOVE_USERMAN" == "y" ] || return 0
echo1 "removing userman files"
rm_files "${FILESYSTEM_MOD_DIR}/bin/usermand" \
	 $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name userman) \
	 $(find ${HTML_LANG_MOD_DIR} -name 'userlist*' -o -name 'useradd*')
for j in userlist useradd; do
	for i in $(find "${HTML_LANG_MOD_DIR}" -type f | xargs grep -l $j); do
		sed -i -e "/$j/d" $i
	done
done
if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	sed -i -e "s/KIDS=y/KIDS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
else
	sed -i -e "s/CONFIG_KIDS=y/CONFIG_KIDS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
fi

