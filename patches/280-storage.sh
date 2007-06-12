if [ "$DS_HAS_USB_HOST" == "y" ]
then
	echo1 "patching run_mount"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/storage.patch"
fi
