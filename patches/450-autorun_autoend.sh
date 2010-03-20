[ "$FREETZ_AUTORUN_AUTOEND" == "y" ] || return 0
echo1 "patching run_mount and storage: autorun/autoend"
if isFreetzType 7270 7270_V3 && isFreetzType LABOR_PHONE LABOR_NAS LABOR_CORE LABOR_IPV6; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount_${FREETZ_TYPE_STRING}.patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage_${FREETZ_TYPE_STRING}.patch"
elif isFreetzType 3270 3270_V3 7141 7170 7240 7270 7270_V3 || \
	( isFreetzType 7140 && isFreetzType LANG_EN LANG_A_CH); then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount_7270.patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage_7270.patch"
elif isFreetzType 7150; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount_7150.patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage_7150.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount.patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage.patch"
fi
