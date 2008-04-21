[ "$FREETZ_HAS_USB_HOST" == "y" ] || return 0
echo1 "patching run_mount"
if [ "$FREETZ_TYPE_FON_WLAN_7270" == "y" ]; then
	if [ "$FREETZ_TYPE_LABOR" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7270_labor.patch"
	else
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7270.patch"
	fi
elif [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_PHONE" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7170_labor_phone.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_MINI" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7170_labor_phone.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_GAMING" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7170_labor_phone.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_BETA" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7170_labor_phone.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_DSL" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage_7170_labor_phone.patch"
elif [ "$FREETZ_TYPE_SPEEDPORT_W900V" != "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage.patch"
fi
