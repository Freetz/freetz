[ "$FREETZ_PATCH_ALARMCLOCK" == "y" ] || return 0
echo1 "adding alarm-clock"

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/480-add_3rd_alarmclock/alarmclock_${FREETZ_TYPE_PREFIX}.patch"

