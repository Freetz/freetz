if [ "$FREETZ_TYPE_LANG_EN" == "y" ]; then
	if [ "$FREETZ_TYPE_ANNEX_A" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/en/rc.S-logging-7170-annexa.patch"
	else
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/en/rc.S-logging-7170-annexb.patch"
	fi
fi
