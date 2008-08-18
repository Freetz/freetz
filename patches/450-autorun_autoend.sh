[ "$FREETZ_AUTORUN_AUTOEND" == "y" ] || return 0
echo1 "patching run_mount and storage: autorun/autoend"
if [ "$FREETZ_TYPE_LABOR_GAMING" ] || [ "$FREETZ_TYPE_WLAN_3270" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount-labor_gaming.patch"
elif [ "$FREETZ_TYPE_LABOR_ALL" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount-labor_all.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount.patch"
fi
if [ "$FREETZ_TYPE_LABOR_ALL" ]; then
    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage_labor_all.patch"
else
    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage.patch"
fi

