[ "$FREETZ_REMOVE_CDROM_ISO" == "y" ] || return 0
echo1 "removing cdrom.iso"
rm -f "${FILESYSTEM_MOD_DIR}/lib/modules/cdrom.iso"
sed -i -e 's/cdrom_fallback=0/cdrom_fallback=1/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
if [ "$FREETZ_TYPE_FON_5050" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback_5050.patch"
elif [ "$FREETZ_TYPE_FON" == "y" -a "$FREETZ_TYPE_LANG_DE" ] || \
	[ "$FREETZ_TYPE_300IP_AS_FON" == "y" -a "$FREETZ_TYPE_LANG_DE" ] || \
	[ "$FREETZ_TYPE_WLAN_3020" == "y" ] || [ "$FREETZ_TYPE_WLAN_3030" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN" == "y"  -a "$FREETZ_TYPE_LANG_DE" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback_fon.patch"
elif [ "$FREETZ_TYPE_FON" == "y" -a "$FREETZ_TYPE_LANG_EN" ] || \
	[ "$FREETZ_TYPE_300IP_AS_FON" == "y" -a "$FREETZ_TYPE_LANG_EN" ]|| \
	[ "$FREETZ_TYPE_FON_WLAN" == "y"  -a "$FREETZ_TYPE_LANG_EN" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback_fon_04.49.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback.patch"
fi

