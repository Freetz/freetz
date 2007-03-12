if [ "$DS_REMOVE_CDROM_ISO" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}removing cdrom.iso"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/modules/cdrom.iso"
	f [ "$DS_TYPE_FON_5050" == "y" ]
	then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback_5050.patch"
	else
		sed -i -e 's/cdrom_fallback=0/cdrom_fallback=1/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback.patch"
	fi
fi
