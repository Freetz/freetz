[ "$DS_HAS_USB_HOST" == "y" ] || return 0
echo1 "patching run_mount"
if [ "$DS_TYPE_FON_WLAN_7270" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7270.patch"
elif [ "$DS_TYPE_SPEEDPORT_W900V" != "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage.patch"
fi
