if [ "$DS_REMOVE_CDROM_ISO" == "y" ]; then
	echo1 "removing cdrom.iso"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/modules/cdrom.iso"
	sed -i -e 's/cdrom_fallback=0/cdrom_fallback=1/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	if [ "$DS_TYPE_FON_5050" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback_5050.patch"
	elif [ "$DS_TYPE_FON" == "y" ] || [ "$DS_TYPE_300IP_AS_FON" == "y" ] \
		|| [ "$DS_TYPE_WLAN_3020" == "y" ] || [ "$DS_TYPE_WLAN_3030" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback_fon.patch"
	else
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback.patch"
	fi
fi
