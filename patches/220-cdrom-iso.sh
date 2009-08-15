[ "$FREETZ_REMOVE_CDROM_ISO" == "y" ] || return 0
echo1 "removing cdrom.iso"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/cdrom.iso"
sed -i -e 's/cdrom_fallback=0/cdrom_fallback=1/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
if isFreetzType 5050; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback_5050.patch"
elif isFreetzType 3020 3030 || \
	( isFreetzType 300IP_AS_FON FON FON_WLAN && isFreetzType LANG_DE ); then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback_fon.patch"
elif isFreetzType 300IP_AS_FON FON FON_WLAN && isFreetzType LANG_EN; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback_fon_04.49.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/rc.S-no-cdrom-fallback.patch"
fi

