[ "$FREETZ_PATCH_MULTIPLE_PRINTERS" == "y" ] || return 0
	echo1 "adding support for multiple printers"

	if isFreetzType 7170 && ! isFreetzType LABOR_PREVIEW; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/275-multiple_printers_7170.patch"
	elif isFreetzType 3270 3270_V3 7170 7240 7270 7340 7390; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/275-multiple_printers_fw86.patch"
	else
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/275-multiple_printers.patch"
	fi
