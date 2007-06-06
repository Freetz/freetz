if [ "$DS_HAS_USB_HOST" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}patching run_mount"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/run_mount.patch"
fi
