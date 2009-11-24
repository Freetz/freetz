[ "$FREETZ_PATCH_ALARMCLOCK" == "y" ] || return 0
echo1 "adding alarm-clock"

if isFreetzType 7170 7141 && isFreetzType LANG_DE; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/480-alarmclock.patch"
fi

if isFreetzType 7270 7270_V3 3270; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock.patch"
fi

