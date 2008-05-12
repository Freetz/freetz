[ "$FREETZ_HAS_USB_HOST" == "y" ] || return 0
echo1 "patching run_mount"
if [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7170.patch"
elif [ "$FREETZ_TYPE_FON_7150" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7170.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7270" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7270.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7140" == "y" -a "$FREETZ_TYPE_LANG_EN" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/en/storage_7140.patch"
elif [ "$FREETZ_TYPE_SPEEDPORT_W900V" != "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage.patch"
fi
