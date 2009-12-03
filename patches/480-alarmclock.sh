[ "$FREETZ_PATCH_ALARMCLOCK" == "y" ] || return 0
echo1 "adding alarm-clock"

if isFreetzType 7150 && isFreetzType LANG_DE; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/480-alarmclock_7150.patch"
fi

if isFreetzType 7112 7141 7170 && isFreetzType LANG_DE; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/480-alarmclock.patch"
fi

if isFreetzType 3270_V3; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock_3020v3.patch"
fi

if isFreetzType 3270 7240 7270 7270_V3; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock.patch"
fi

