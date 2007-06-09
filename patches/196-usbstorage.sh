if [ "$DS_PATCH_USBSTORAGE" == "y" ]
then
	echo1 "applying USB storage patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage.patch"
fi
