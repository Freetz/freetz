[ "$FREETZ_PATCH_MULTIPLE_PRINTERS" == "y" ] || return 0
	echo1 "adding support for multiple printers"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/275-multiple_printers.patch"
