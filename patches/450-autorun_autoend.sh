[ "$FREETZ_AUTORUN_AUTOEND" == "y" ] || return 0
echo1 "patching run_mount and storage: autorun/autoend"
if  [ "$FREETZ_TYPE_WLAN_3270" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount_3270.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7170" ] || [ "$FREETZ_TYPE_FON_WLAN_7240" ] || [ "$FREETZ_TYPE_FON_WLAN_7270" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount_7270.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount.patch"
fi
if  [ "$FREETZ_TYPE_FON_WLAN_7170" ] || [ "$FREETZ_TYPE_FON_WLAN_7240" ] || [ "$FREETZ_TYPE_FON_WLAN_7270" ]; then
    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage_7270.patch"
else
    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage.patch"
fi

