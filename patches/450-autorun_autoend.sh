[ "$FREETZ_AUTORUN_AUTOEND" == "y" ] || return 0
echo1 "patching run_mount and storage: autorun/autoend"
if [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_DSL" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount_7170_labor_dsl.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7141" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7170" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7240"  == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7270"  == "y"  ] || \
	[ "$FREETZ_TYPE_WLAN_3270" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount_7270.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autorun-run_mount.patch"
fi
if  [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_DSL" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage_7170_labor_dsl.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7141" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7170" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7240" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7270" == "y" ] || \
	[ "$FREETZ_TYPE_WLAN_3270" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage_7270.patch"
else
    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/450-autoend-storage.patch"
fi

