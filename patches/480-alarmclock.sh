[ "$FREETZ_PATCH_ALARMCLOCK" == "y" ] || return 0
echo1 "adding alarm-clock"

if isFreetzType 7150 && isFreetzType LANG_DE; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/480-alarmclock_7150.patch"
elif isFreetzType 7112 7141 7170 && isFreetzType LANG_DE; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/480-alarmclock.patch"
elif isFreetzType 3270_V3; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock_3020v3.patch"
elif isFreetzType 7270 7270_V3 && isFreetzType LABOR_PHONE LABOR_NAS; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock_7270_labor_phone_nas.patch"
elif isFreetzType 7270 7270_V3 && isFreetzType LABOR_PHONE LABOR_CORE; then
        modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock_7270_labor_core.patch"
elif isFreetzType 3270 7240 7270 7270_V3; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock.patch"
fi

