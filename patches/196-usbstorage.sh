if [ "$DS_PATCH_USBSTORAGE" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}applying USB storage patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage.patch"
fi
