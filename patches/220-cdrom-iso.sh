if [ "$DS_REMOVE_CDROM_ISO" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}removing cdrom.iso"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/modules/cdrom.iso"
	if [ "$DS_TYPE_WLAN_3050" == "y" -o "$DS_TYPE_WLAN_3070" == "y" ]
	then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.USB-no-cdrom-fallback_3050_3070.patch"
	elif [ "$DS_TYPE_FON_5050" == "y" ]
	then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.USB-no-cdrom-fallback_5050.patch"
	else
		sed -i -e 's/cdrom_fallback=0/cdrom_fallback=1/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.USB"
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.USB-no-cdrom-fallback.patch"
	fi
fi
